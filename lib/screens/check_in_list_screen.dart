import 'package:flutter/material.dart';

import '../services/apiconnect.dart';

class CheckInListScreen extends StatefulWidget {
  const CheckInListScreen({super.key});

  @override
  State<CheckInListScreen> createState() => _CheckInListScreenState();
}

class _CheckInListScreenState extends State<CheckInListScreen> {
  List<dynamic> _checkIns = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final checkIns = await ApiService.obtenerCheckIns();
      setState(() {
        _checkIns = checkIns;
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
        title: const Text('Lista de Check-ins'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCheckIns,
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
                    'Error al cargar check-ins',
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
                    onPressed: _loadCheckIns,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _checkIns.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay check-ins registrados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCheckIns,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _checkIns.length,
                itemBuilder: (context, index) {
                  final checkIn = _checkIns[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(Icons.person, color: Colors.green),
                      ),
                      title: Text(
                        checkIn['fullName'] ?? 'Sin nombre',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (checkIn['document'] != null)
                            Text('Documento: ${checkIn['document']}'),
                          if (checkIn['email'] != null)
                            Text('Email: ${checkIn['email']}'),
                          if (checkIn['phone'] != null)
                            Text('Teléfono: ${checkIn['phone']}'),
                          if (checkIn['reservationNumber'] != null)
                            Text('Reserva: ${checkIn['reservationNumber']}'),
                          if (checkIn['arrivalDate'] != null)
                            Text('Llegada: ${checkIn['arrivalDate']}'),
                          if (checkIn['departureDate'] != null)
                            Text('Salida: ${checkIn['departureDate']}'),
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
