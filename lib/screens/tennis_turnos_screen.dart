import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/apiconnect.dart';

class TennisTurnosScreen extends StatefulWidget {
  final DateTime fechaSeleccionada;
  final int idClub;
  final int idDeporte;
  final String dni;
  final String nombrecompleto;

  const TennisTurnosScreen({
    super.key,
    required this.fechaSeleccionada,
    required this.idClub,
    required this.idDeporte,
    required this.dni,
    required this.nombrecompleto,
  });

  @override
  State<TennisTurnosScreen> createState() => _TennisTurnosScreenState();
}

class _TennisTurnosScreenState extends State<TennisTurnosScreen> {
  late Future<List<Map<String, dynamic>>> _canchasFuture;
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _selectedCancha;
  String _tipoJuego = '';
  final List<String> _nombresJugadores = [];
  bool _reservaActiva = false;
  bool _esAdmin = false;
  String _motivoReserva = '';
  double _precioLuz = 0.0;
  String? _ultimaReservaHora;

  @override
  void initState() {
    super.initState();
    _canchasFuture = _getCanchasDisponibles();
    _verificarReservaActiva();
    _validarUsuarioAdmin();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getCanchasDisponibles() async {
    final canchas = await ApiService.obtenerCanchasDisponibles(
      widget.idClub,
      widget.idDeporte,
    );

    if (canchas.isNotEmpty) {
      setState(() {
        _selectedCancha = canchas.first;
      });
    }

    return canchas;
  }

  Future<void> _verificarReservaActiva() async {
    try {
      final reservasJson = await ApiService.obtenerReservasPorDNI(widget.dni);
      final ahora = DateTime.now();

      bool tieneReservaActiva = reservasJson.any((reserva) {
        final fechaReservaStr = reserva['fecha_y_hora'] as String?;
        if (fechaReservaStr == null) return false;

        final fechaReserva = DateTime.tryParse(fechaReservaStr);
        if (fechaReserva == null) return false;

        final deporteId = reserva['deporte_id'];
        if (deporteId != null && deporteId != widget.idDeporte) return false;

        return fechaReserva.isAfter(ahora);
      });

      if (mounted) {
        setState(() {
          _reservaActiva = tieneReservaActiva;
        });
      }
    } catch (_) {
      // Ignoramos errores silenciosamente
    }
  }

  void _validarUsuarioAdmin() {
    if (widget.dni == '0') {
      setState(() {
        _esAdmin = true;
      });
    }
  }

  Future<void> _calcularPrecioLuz(String horaTurno) async {
    if (_selectedCancha == null) return;

    final turnos = await _apiService.obtenerTurnosDisponiblesPorCancha(
      _selectedCancha?['id'],
      DateFormat('yyyy-MM-dd').format(widget.fechaSeleccionada),
    );

    final turno = turnos.firstWhere(
      (t) => t['horaInicio'] == horaTurno,
      orElse: () => {},
    );

    if (turno.isNotEmpty && (turno['tieneLuz'] == 1 || turno['tieneLuz'] == true)) {
      setState(() {
        _precioLuz = (_selectedCancha?['precioLuz'] ?? 0).toDouble();
      });
    } else {
      setState(() {
        _precioLuz = 0.0;
      });
    }
  }

  void _mostrarPopupTipoJuego(
    BuildContext context,
    String fechaSeleccionada,
    String horaTurno,
    List<dynamic> turnosDisponibles,
  ) async {
    if (_reservaActiva && !_esAdmin) {
      _mostrarAlerta(context, 'Ya tienes una reserva activa.');
      return;
    }

    final parentContext = context;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: Text(_esAdmin ? 'Motivo de la reserva' : 'Seleccionar Tipo de Juego'),
              content: _esAdmin
                  ? TextField(
                      onChanged: (value) => _motivoReserva = value,
                      decoration: const InputDecoration(hintText: 'Motivo'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTipoJuegoTile(setState, 'single', 'Single'),
                        const SizedBox(height: 8),
                        _buildTipoJuegoTile(setState, 'doble', 'Doble'),
                        const SizedBox(height: 16),
                        Text(
                          'Dueño: ${widget.nombrecompleto}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (_esAdmin) {
                      if (_motivoReserva.trim().isEmpty) {
                        _mostrarAlerta(context, 'Por favor ingresa un motivo.');
                        return;
                      }
                      Navigator.pop(context);
                      _crearReservaAdmin(_motivoReserva, horaTurno);
                      return;
                    }

                    if (_tipoJuego.isEmpty) {
                      _mostrarAlerta(context, 'Selecciona un tipo de juego.');
                      return;
                    }

                    final indiceTurno = turnosDisponibles.indexWhere(
                      (turno) => turno['horaInicio'] == horaTurno,
                    );
                    if (indiceTurno == -1) {
                      _mostrarAlerta(context, 'Turno no encontrado.');
                      return;
                    }

                    final turno = turnosDisponibles[indiceTurno];
                    final turnosNecesarios = (_tipoJuego == 'single')
                        ? (turno['tipoSingle'] ?? 1)
                        : (turno['tipoDoble'] ?? 2);

                    if (indiceTurno + turnosNecesarios > turnosDisponibles.length) {
                      _mostrarAlerta(parentContext, 'No hay suficientes turnos seguidos disponibles.');
                      return;
                    }

                    final puedeReservar = List.generate(turnosNecesarios, (i) {
                      final turnoActual = turnosDisponibles[indiceTurno + i];
                      return !(turnoActual['ocupado'] ?? false);
                    }).every((disponible) => disponible);

                    if (!puedeReservar) {
                      _mostrarAlerta(parentContext, 'Al menos uno de los turnos está ocupado.');
                      return;
                    }

                    Navigator.pop(dialogContext);
                    _mostrarPopupAsignarJugadores(
                      parentContext,
                      fechaSeleccionada,
                      horaTurno,
                      indiceTurno,
                      turnosDisponibles,
                      turnosNecesarios,
                    );
                  },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTipoJuegoTile(
    StateSetter setState,
    String tipo,
    String titulo,
  ) {
    final seleccionado = _tipoJuego == tipo;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: seleccionado ? Colors.orange : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(titulo),
        trailing: seleccionado ? const Icon(Icons.check_circle, color: Colors.orange) : null,
        onTap: () {
          setState(() => _tipoJuego = tipo);
        },
        tileColor: seleccionado ? Colors.orange.withOpacity(0.1) : null,
      ),
    );
  }

  void _mostrarPopupAsignarJugadores(
    BuildContext parentContext,
    String fechaSeleccionada,
    String horaTurno,
    int indiceTurno,
    List<dynamic> turnosDisponibles,
    int turnosNecesarios,
  ) async {
    final cantidadJugadores = _tipoJuego == 'single' ? 2 : 4;
    final jugadores = List<String?>.filled(cantidadJugadores, null);

    await showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Asignar Jugadores ($_tipoJuego)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(cantidadJugadores, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Jugador ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      value: jugadores[index],
                      items: const [
                        DropdownMenuItem(value: 'Socio', child: Text('Socio')),
                        DropdownMenuItem(value: 'Invitado', child: Text('Invitado')),
                        DropdownMenuItem(value: 'Carnet Tenis', child: Text('Carnet Tenis')),
                        DropdownMenuItem(value: 'Profesor', child: Text('Profesor')),
                      ],
                      onChanged: (value) {
                        setState(() => jugadores[index] = value);
                      },
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (jugadores.any((jugador) => jugador == null)) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Completa todos los jugadores.')),
                      );
                      return;
                    }

                    _nombresJugadores
                      ..clear()
                      ..addAll(jugadores.cast<String>());

                    Navigator.pop(dialogContext);
                    await _calcularPrecioLuz(horaTurno);
                    if (!mounted) return;
                    _mostrarDetallesReserva(
                      parentContext,
                      fechaSeleccionada,
                      horaTurno,
                      jugadores,
                    );
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDetallesReserva(
    BuildContext context,
    String fechaSeleccionada,
    String horaTurno,
    List<String?> jugadores,
  ) {
    if (_selectedCancha == null) return;

    final fecha = DateTime.parse('$fechaSeleccionada $horaTurno');
    double total = 0.0;
    final buffer = StringBuffer();

    for (final jugador in jugadores) {
      if (jugador == null) continue;

      double precio;
      switch (jugador) {
        case 'Socio':
          precio = (_selectedCancha?['precioSocio'] ?? 0).toDouble();
          break;
        case 'Invitado':
          precio = (_selectedCancha?['precioInvitado'] ?? 0).toDouble();
          break;
        case 'Carnet Tenis':
          precio = (_selectedCancha?['precioCarnetTenis'] ?? 0).toDouble();
          break;
        case 'Profesor':
          precio = (_selectedCancha?['precioProfesor'] ?? 0).toDouble();
          break;
        default:
          precio = 0.0;
      }
      total += precio;
      buffer.writeln('$jugador (\$${precio.toStringAsFixed(2)})');
    }

    if (_precioLuz > 0) {
      total += _precioLuz;
      buffer.writeln('Luz (\$${_precioLuz.toStringAsFixed(2)})');
    }

    final reservaData = <String, dynamic>{
      'dni': widget.dni,
      'nombreCompleto': widget.nombrecompleto,
      'fechaYHora': fecha.toIso8601String(),
      'canchaId': _selectedCancha?['id'],
      'tipoDeporte': _tipoJuego == 'single' ? 1 : 2,
      'jugadores': _esAdmin ? _motivoReserva : _nombresJugadores.join('//'),
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalles de la Reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(fecha)}'),
              const SizedBox(height: 8),
              Text('Cancha: ${_selectedCancha?['nombreCancha'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Jugadores:\n$buffer'),
              const SizedBox(height: 8),
              Text('Total: \$${total.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _crearReservaDirecta(reservaData);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAlerta(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _crearReservaAdmin(String motivoReserva, String horaTurno) {
    if (_selectedCancha == null) return;

    final fecha = DateTime.parse('${widget.fechaSeleccionada.toIso8601String().substring(0, 10)} $horaTurno');
    final reservaData = {
      'dni': widget.dni,
      'nombreCompleto': widget.nombrecompleto,
      'fechaYHora': fecha.toIso8601String(),
      'canchaId': _selectedCancha?['id'],
      'tipoDeporte': widget.idDeporte,
      'jugadores': motivoReserva,
    };

    _ultimaReservaHora = horaTurno;

    ApiService.crearReserva(reservaData).then((_) {
      if (!mounted) return;
      _refrescarDespuesDeReserva();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva de administrador creada'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((_) {
      if (!mounted) return;
      _mostrarAlerta(context, 'No se pudo crear la reserva.');
    });
  }

  void _crearReservaDirecta(Map<String, dynamic> reservaData) {
    _ultimaReservaHora = DateFormat('HH:mm').format(DateTime.parse(reservaData['fechaYHora']));

    ApiService.crearReserva(reservaData).then((_) {
      if (!mounted) return;
      _refrescarDespuesDeReserva();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva creada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((_) {
      if (!mounted) return;
      _mostrarAlerta(context, 'No se pudo crear la reserva.');
    });
  }

  void _refrescarDespuesDeReserva() {
    setState(() {
      _verificarReservaActiva();
      _canchasFuture = _getCanchasDisponibles();
    });
    _scrollToReservation();
  }

  void _scrollToReservation() {
    if (_ultimaReservaHora == null) return;

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted || _selectedCancha == null) return;

      final turnos = await _apiService.obtenerTurnosDisponiblesPorCancha(
        _selectedCancha?['id'],
        DateFormat('yyyy-MM-dd').format(widget.fechaSeleccionada),
      );

      final targetIndex = turnos.indexWhere(
        (turno) => turno['horaInicio'] == _ultimaReservaHora,
      );

      if (targetIndex != -1 && _scrollController.hasClients) {
        _scrollController.animateTo(
          targetIndex * 80.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

      _ultimaReservaHora = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turnos - ${DateFormat('dd/MM/yyyy').format(widget.fechaSeleccionada)}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _canchasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las canchas'));
          }

          final canchas = snapshot.data ?? [];

          if (canchas.isEmpty) {
            return const Center(child: Text('No hay canchas disponibles.'));
          }

          final dropdown = Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedCancha,
              isExpanded: true,
              items: canchas.map((cancha) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: cancha,
                  child: Text(cancha['nombreCancha'] ?? 'Nombre no disponible'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCancha = value;
                });
              },
              hint: const Text('Selecciona una cancha'),
            ),
          );

          return Column(
            children: [
              dropdown,
              const SizedBox(height: 8),
              Expanded(
                child: _selectedCancha == null
                    ? const Center(child: Text('Selecciona una cancha para ver los turnos.'))
                    : _buildTurnosList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTurnosList() {
    final fechaISO = DateFormat('yyyy-MM-dd').format(widget.fechaSeleccionada);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _apiService.obtenerTurnosDisponiblesPorCancha(
          _selectedCancha?['id'],
          fechaISO,
        ),
        ApiService.obtenerReservas(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar turnos.'));
        }

        final turnosData = snapshot.data?[0] ?? [];
        final reservasData = (snapshot.data?[1] ?? [])
            .cast<Map<String, dynamic>>();

        List<Map<String, dynamic>> turnos =
            turnosData.cast<Map<String, dynamic>>();

        final reservasPorCancha = reservasData.where((reserva) {
          final canchaIdReserva = reserva['cancha_id'];
          return canchaIdReserva == _selectedCancha?['id'];
        }).toList();

        final hoy = DateTime.now();
        final esHoy = hoy.year == widget.fechaSeleccionada.year &&
            hoy.month == widget.fechaSeleccionada.month &&
            hoy.day == widget.fechaSeleccionada.day;

        if (esHoy) {
          turnos = turnos.where((turno) {
            final horaStr = turno['horaInicio'] as String?;
            if (horaStr == null || horaStr.isEmpty) {
              return false;
            }

            final partes = horaStr.split(':');
            final hora = int.tryParse(partes.isNotEmpty ? partes[0] : '') ?? 0;
            final minuto = int.tryParse(partes.length > 1 ? partes[1] : '') ?? 0;

            final turnoDateTime = DateTime(
              widget.fechaSeleccionada.year,
              widget.fechaSeleccionada.month,
              widget.fechaSeleccionada.day,
              hora,
              minuto,
            );

            return turnoDateTime.isAfter(hoy);
          }).toList();
        }

        if (turnos.isEmpty) {
          return const Center(child: Text('No hay turnos disponibles para esta fecha.'));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: turnos.length,
          itemBuilder: (context, index) {
            final turno = turnos[index];
            final hora = turno['horaInicio'] as String? ?? '--:--';
            bool ocupado = turno['ocupado'] == true;

            final partes = hora.split(':');
            final horaInt = int.tryParse(partes.isNotEmpty ? partes[0] : '') ?? 0;
            final minutoInt = int.tryParse(partes.length > 1 ? partes[1] : '') ?? 0;

            final turnoFechaStr = turno['fecha'] as String? ?? '';
            if (turnoFechaStr.isEmpty) {
              return const SizedBox.shrink();
            }

            final turnoFecha = DateTime.parse(turnoFechaStr);
            final turnoDateTimeLocal = DateTime(
              turnoFecha.year,
              turnoFecha.month,
              turnoFecha.day,
              horaInt,
              minutoInt,
            );
            final turnoDateTimeUtc = DateTime.utc(
              turnoFecha.year,
              turnoFecha.month,
              turnoFecha.day,
              horaInt,
              minutoInt,
            );

            Map<String, dynamic>? reservaCoincidente;

            for (final reserva in reservasPorCancha) {
              final fechaReservaStr = reserva['fecha_y_hora'] as String?;
              if (fechaReservaStr == null) continue;

              final fechaReservaUtc = DateTime.tryParse(fechaReservaStr)?.toUtc();
              if (fechaReservaUtc == null) continue;

              if (fechaReservaUtc == turnoDateTimeUtc) {
                reservaCoincidente = reserva;
                ocupado = true;
                break;
              }
            }

            final turnoDateTime = turnoDateTimeLocal;

            if (!ocupado) {
              for (final reserva in reservasPorCancha) {
                final fechaReservaStr = reserva['fecha_y_hora'] as String?;
                if (fechaReservaStr == null) continue;

                final fechaReservaLocal = DateTime.tryParse(fechaReservaStr);
                if (fechaReservaLocal == null) continue;

                if (fechaReservaLocal.year == turnoDateTime.year &&
                    fechaReservaLocal.month == turnoDateTime.month &&
                    fechaReservaLocal.day == turnoDateTime.day &&
                    fechaReservaLocal.hour == turnoDateTime.hour &&
                    fechaReservaLocal.minute == turnoDateTime.minute) {
                  reservaCoincidente = reserva;
                  ocupado = true;
                  break;
                }
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(
                  ocupado ? Icons.lock : Icons.access_time,
                  color: ocupado ? Colors.red : Colors.green,
                ),
                title: Text(
hora,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ocupado ? Colors.grey : Colors.black87,
                  ),
                ),
                subtitle: ocupado
                    ? Text(
                        'RESERVADO por ${reservaCoincidente?['nombre_completo'] ?? 'Desconocido'}',
                        style: const TextStyle(color: Colors.red),
                      )
                    : const Text(
                        'DISPONIBLE',
                        style: TextStyle(color: Colors.green),
                      ),
                trailing: (turno['tieneLuz'] == 1 || turno['tieneLuz'] == true)
                    ? const Icon(Icons.lightbulb, color: Colors.amber)
                    : null,
                onTap: ocupado
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El turno seleccionado ya está reservado'),
                          ),
                        );
                      }
                    : () {
                        _mostrarPopupTipoJuego(
                          context,
                          fechaISO,
                          hora,
                          turnos,
                        );
                      },
              ),
            );
          },
        );
      },
    );
  }
}

