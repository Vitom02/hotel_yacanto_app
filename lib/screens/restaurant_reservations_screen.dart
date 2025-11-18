import 'package:flutter/material.dart';

import '../services/apiconnect.dart';
import 'restaurant_reservations_list_screen.dart';

class RestaurantReservationsScreen extends StatefulWidget {
  const RestaurantReservationsScreen({super.key});

  @override
  State<RestaurantReservationsScreen> createState() =>
      _RestaurantReservationsScreenState();
}

class _RestaurantReservationsScreenState
    extends State<RestaurantReservationsScreen> {
  final List<String> _timeSlots = ['20:30', '22:00'];
  final List<DateTime> _dates = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  final Map<String, int> _reservations = {};
  late DateTime _selectedDate = _dates.first;
  bool _isLoadingReservations = false;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoadingReservations = true;
    });

    try {
      final reservas = await ApiService.obtenerReservasRestaurante();
      final Map<String, int> loadedReservations = {};

      for (var reserva in reservas) {
        // El JSON usa snake_case: reservation_date, time_slot, guest_count
        final date =
            reserva['reservation_date'] as String? ??
            reserva['reservationDate'] as String?;
        final slot =
            reserva['time_slot'] as String? ?? reserva['timeSlot'] as String?;
        final guests =
            (reserva['guest_count'] as num?)?.toInt() ??
            (reserva['guestCount'] as num?)?.toInt() ??
            0;

        if (date != null && slot != null) {
          final key = '$date-$slot';
          loadedReservations.update(
            key,
            (value) => value + guests,
            ifAbsent: () => guests,
          );
        }
      }

      setState(() {
        _reservations.clear();
        _reservations.addAll(loadedReservations);
        _isLoadingReservations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReservations = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar reservas: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas Restaurante'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const RestaurantReservationsListScreen(),
                ),
              );
            },
            tooltip: 'Ver todas las reservas',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onViewMenuTap,
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Ver menú'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccioná la fecha',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final bool isSelected =
                      date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.brown : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.brown
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatWeekday(date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            _formatMonth(date),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Horarios disponibles (${_formatDate(_selectedDate)})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _timeSlots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final slot = _timeSlots[index];
                  final String key = _reservationKey(_selectedDate, slot);
                  final int reserved = _reservations[key] ?? 0;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown.withOpacity(0.1),
                        child: Icon(
                          Icons.schedule,
                          color: Colors.brown.shade700,
                        ),
                      ),
                      title: Text(
                        slot,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        reserved == 0
                            ? 'Sin reservas registradas'
                            : '$reserved comensales confirmados',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openReservationDialog(slot),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onViewMenuTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente podrás ver el menú desde aquí.'),
      ),
    );
  }

  Future<void> _openReservationDialog(String slot) async {
    int guests = 2;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Horario: $slot'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: guests,
              items: List.generate(
                8,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1} comensal(es)'),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  guests = value;
                }
              },
              decoration: const InputDecoration(
                labelText: 'Cantidad de comensales',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmReservation(slot, guests);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReservation(String slot, int guests) async {
    // Mostrar indicador de carga
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Convertir fecha a formato YYYY-MM-DD
      final String reservationDate =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      final reservaData = {
        'reservationDate': reservationDate,
        'timeSlot': slot,
        'guestCount': guests,
      };

      final result = await ApiService.registrarReservaRestaurante(reservaData);

      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result['success'] == true) {
        // Recargar reservas desde la API
        await _loadReservations();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['mensaje']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['mensaje']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _reservationKey(DateTime date, String slot) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-$slot';

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatMonth(DateTime date) {
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    return months[date.month - 1];
  }

  String _formatWeekday(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }
}
