import 'package:flutter/material.dart';

import '../services/apiconnect.dart';

class RestaurantReservationsListScreen extends StatefulWidget {
  const RestaurantReservationsListScreen({super.key});

  @override
  State<RestaurantReservationsListScreen> createState() =>
      _RestaurantReservationsListScreenState();
}

class _RestaurantReservationsListScreenState
    extends State<RestaurantReservationsListScreen> {
  List<dynamic> _reservas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  Future<void> _loadReservas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservas = await ApiService.obtenerReservasRestaurante();
      setState(() {
        _reservas = reservas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas las Reservas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReservas,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar reservas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadReservas,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _reservas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay reservas registradas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReservas,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reservas.length,
                itemBuilder: (context, index) {
                  final reserva = _reservas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown.withOpacity(0.1),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.brown,
                        ),
                      ),
                      title: Text(
                        reserva['time_slot'] ??
                            reserva['timeSlot'] ??
                            'Sin horario',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (reserva['reservation_date'] != null ||
                              reserva['reservationDate'] != null)
                            Text(
                              'Fecha: ${reserva['reservation_date'] ?? reserva['reservationDate']}',
                            ),
                          if (reserva['guest_count'] != null ||
                              reserva['guestCount'] != null)
                            Text(
                              'Comensales: ${reserva['guest_count'] ?? reserva['guestCount']}',
                            ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
