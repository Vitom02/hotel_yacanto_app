import 'package:flutter/material.dart';
import 'tennis_turnos_screen.dart';
import '../services/local_storage.dart';
import '../services/apiconnect.dart';

class TennisScreen extends StatefulWidget {
  const TennisScreen({super.key});

  static const int idClub = 9;
  static const int idDeporte = 1;

  @override
  State<TennisScreen> createState() => _TennisScreenState();
}

class _TennisScreenState extends State<TennisScreen> {
  String? _dni;
  String? _nombreCompleto;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final documento = LocalStorage.getDocument();
      
      if (documento == null || documento.isEmpty) {
        setState(() {
          _error = 'No se encontró documento guardado';
          _isLoading = false;
        });
        return;
      }

      final checkIns = await ApiService.obtenerCheckIns();
      
      final checkIn = checkIns.firstWhere(
        (ci) => ci['document']?.toString() == documento,
        orElse: () => null,
      );
      
      if (checkIn == null) {
        setState(() {
          _error = 'No se encontró información de check-in';
          _isLoading = false;
        });
        return;
      }

      final nombreCompleto = checkIn['full_name'] as String? ?? 
                            checkIn['nombre_completo'] as String? ??
                            checkIn['nombre'] as String? ??
                            'Usuario';

      setState(() {
        _dni = documento;
        _nombreCompleto = nombreCompleto;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tenis'),
          centerTitle: true,
          elevation: 4,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _dni == null || _nombreCompleto == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tenis'),
          centerTitle: true,
          elevation: 4,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Error al cargar datos',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenis'),
        centerTitle: true,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          final DateTime date = DateTime.now().add(Duration(days: index));
          final bool isToday = index == 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Icon(
                Icons.calendar_today,
                color: isToday ? Colors.orange : Colors.orange.shade300,
                size: 32,
              ),
              title: Text(
                _formatDayName(date),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 18,
                  color: isToday ? Colors.orange : Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: isToday
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HOY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TennisTurnosScreen(
                      fechaSeleccionada: date,
                      idClub: TennisScreen.idClub,
                      idDeporte: TennisScreen.idDeporte,
                      dni: _dni!,
                      nombrecompleto: _nombreCompleto!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDayName(DateTime date) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
}

