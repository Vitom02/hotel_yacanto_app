import 'package:flutter/material.dart';
import '../services/apiconnect.dart';
import '../services/local_storage.dart';

class MyRoomScreen extends StatefulWidget {
  const MyRoomScreen({super.key});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  bool _isLoading = true;
  String? _roomNumber;
  String? _errorMessage;
  Map<String, dynamic>? _roomData;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final document = LocalStorage.getDocument();
    if (document == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se encontró el documento. Por favor, complete el check-in primero.';
      });
      return;
    }

    try {
      final result = await ApiService.obtenerHabitacionPorDocumento(document);
      
      if (result['success'] == true) {
        final data = result['data'];
        
        // Verificar si data es una List o un Map
        if (data is List && data.isNotEmpty) {
          // Obtener la fecha actual (solo fecha, sin hora)
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          // Buscar el elemento que coincida con el documento Y tenga la fecha actual dentro del rango
          Map<String, dynamic>? foundItem;
          List<Map<String, dynamic>> matchingDocuments = [];
          
          for (int i = 0; i < data.length; i++) {
            final item = data[i];
            
            if (item is Map<String, dynamic>) {
              // Comparar el documento (puede ser String o int)
              final itemDocument = item['document']?.toString();
              
              if (itemDocument == document) {
                matchingDocuments.add(item);
              }
            }
          }
          
          // Si hay múltiples registros con el mismo documento, buscar el que tenga la fecha actual dentro del rango
          if (matchingDocuments.isNotEmpty) {
            for (var item in matchingDocuments) {
              try {
                final startDateStr = item['start_date']?.toString();
                final endDateStr = item['end_date']?.toString();
                
                if (startDateStr != null && endDateStr != null) {
                  // Parsear fechas (pueden venir en formato ISO 8601)
                  DateTime? startDate;
                  DateTime? endDate;
                  
                  try {
                    startDate = DateTime.parse(startDateStr);
                    endDate = DateTime.parse(endDateStr);
                    
                    // Normalizar a solo fecha (sin hora)
                    startDate = DateTime(startDate.year, startDate.month, startDate.day);
                    endDate = DateTime(endDate.year, endDate.month, endDate.day);
                    
                    // Verificar si la fecha actual está dentro del rango
                    if (today.isAfter(startDate.subtract(const Duration(days: 1))) && 
                        today.isBefore(endDate.add(const Duration(days: 1)))) {
                      foundItem = item;
                      break;
                    }
                  } catch (e) {
                    // Error al parsear fechas, continuar con el siguiente
                  }
                }
              } catch (e) {
                // Error al procesar fechas, continuar con el siguiente
              }
            }
            
            // Si no se encontró ninguno con fecha válida, tomar el primero como fallback
            if (foundItem == null && matchingDocuments.isNotEmpty) {
              foundItem = matchingDocuments[0];
            }
          }
          
          if (foundItem != null) {
            _roomData = foundItem;
            
            // Intentar obtener el número de habitación de diferentes campos posibles
            _roomNumber = foundItem['room_number']?.toString() ?? 
                          foundItem['numeroHabitacion']?.toString() ?? 
                          foundItem['habitacion']?.toString() ?? 
                          foundItem['roomNumber']?.toString() ?? 
                          foundItem['numero']?.toString() ??
                          foundItem['habitacionNumero']?.toString();
          } else {
            _roomNumber = null;
          }
        } else if (data is Map<String, dynamic>) {
          // Si es un Map directamente
          _roomData = data;
          
          // Intentar obtener el número de habitación de diferentes campos posibles
          _roomNumber = data['room_number']?.toString() ?? 
                        data['numeroHabitacion']?.toString() ?? 
                        data['habitacion']?.toString() ?? 
                        data['roomNumber']?.toString() ?? 
                        data['numero']?.toString() ??
                        data['habitacionNumero']?.toString();
        } else {
          // Si no es ni List ni Map, intentar convertir a String
          _roomNumber = data?.toString();
          _roomData = {'data': data};
        }
      } else {
        if (result['hasRoom'] == false) {
          _roomNumber = null;
        } else {
          _errorMessage = result['mensaje'] ?? 'Error al obtener la habitación';
        }
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: ${e.toString()}';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Habitación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _loadRoom,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _roomNumber == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hotel_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No tiene habitación asignada',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Por favor, contacte a recepción para asignar una habitación.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _loadRoom,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Actualizar'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue.shade300,
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.hotel,
                                      size: 64,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Habitación',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _roomNumber!,
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            if (_roomData != null && _roomData is Map<String, dynamic>)
                              Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Información de la habitación',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...(_roomData as Map<String, dynamic>).entries.map((entry) {
                                        if (entry.key == 'numeroHabitacion' ||
                                            entry.key == 'habitacion' ||
                                            entry.key == 'roomNumber' ||
                                            entry.key == 'numero' ||
                                            entry.key == 'habitacionNumero' ||
                                            entry.key == 'document') {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${entry.key}:',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  entry.value?.toString() ?? 'N/A',
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadRoom,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Actualizar información'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

