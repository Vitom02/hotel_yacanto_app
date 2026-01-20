import 'package:flutter/material.dart';

import '../services/apiconnect.dart';
import '../services/local_storage.dart';
import 'check_in_list_screen.dart';
import 'declarations_screen.dart';
import 'home_screen.dart';

class CheckInFormScreen extends StatefulWidget {
  const CheckInFormScreen({super.key});

  @override
  State<CheckInFormScreen> createState() => _CheckInFormScreenState();
}

class _CheckInFormScreenState extends State<CheckInFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reservationNumberController =
      TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _vehicleDataController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  final FocusNode _documentFocusNode = FocusNode();
  bool _isLoadingData = false;
  bool _dataLoaded = false;
  String _lastSearchedDocument = '';

  String _mealPlan = 'Sólo desayuno';
  String _travelPurpose = 'Turismo';
  int _guestCount = 1;

  @override
  void initState() {
    super.initState();
    _documentFocusNode.addListener(_onDocumentFocusChange);
  }

  @override
  void dispose() {
    _documentFocusNode.removeListener(_onDocumentFocusChange);
    _documentFocusNode.dispose();
    _fullNameController.dispose();
    _documentController.dispose();
    _nationalityController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _reservationNumberController.dispose();
    _arrivalDateController.dispose();
    _departureDateController.dispose();
    _vehicleDataController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  /// Cuando el campo de documento pierde el foco, busca datos previos
  void _onDocumentFocusChange() {
    if (!_documentFocusNode.hasFocus) {
      final documento = _documentController.text.trim();
      if (documento.isNotEmpty && documento != _lastSearchedDocument) {
        _buscarDatosHuesped(documento);
      }
    }
  }

  /// Busca los datos del huésped por documento y los carga en el formulario
  Future<void> _buscarDatosHuesped(String documento) async {
    if (_isLoadingData) return;

    print('🔍 [CheckIn] Buscando datos para documento: $documento');

    setState(() {
      _isLoadingData = true;
      _lastSearchedDocument = documento;
    });

    try {
      final checkInPrevio = await ApiService.buscarCheckInPorDocumento(documento);

      print('📥 [CheckIn] Respuesta de la API: $checkInPrevio');
      print('📥 [CheckIn] Tipo de respuesta: ${checkInPrevio.runtimeType}');
      
      if (checkInPrevio != null) {
        print('📥 [CheckIn] Campos disponibles: ${checkInPrevio.keys.toList()}');
        checkInPrevio.forEach((key, value) {
          print('   - $key: $value (${value.runtimeType})');
        });
      } else {
        print('⚠️ [CheckIn] La API devolvió null - no hay datos previos para este documento');
      }

      if (checkInPrevio != null && mounted) {
        // Cargar solo los datos personales (no los de la reserva)
        // La API puede devolver campos en snake_case o camelCase
        setState(() {
          final fullName = checkInPrevio['fullName'] ?? checkInPrevio['full_name'];
          print('📝 [CheckIn] fullName extraído: $fullName');
          if (fullName != null) {
            _fullNameController.text = fullName.toString();
          }
          
          final nationality = checkInPrevio['nationality'];
          print('📝 [CheckIn] nationality extraído: $nationality');
          if (nationality != null) {
            _nationalityController.text = nationality.toString();
          }
          
          final birthDate = checkInPrevio['birthDate'] ?? checkInPrevio['birth_date'];
          print('📝 [CheckIn] birthDate extraído: $birthDate');
          if (birthDate != null) {
            // Convertir de YYYY-MM-DD a DD/MM/YYYY
            _birthDateController.text = _formatDateForDisplay(birthDate.toString());
          }
          
          final email = checkInPrevio['email'];
          print('📝 [CheckIn] email extraído: $email');
          if (email != null) {
            _emailController.text = email.toString();
          }
          
          final phone = checkInPrevio['phone'];
          print('📝 [CheckIn] phone extraído: $phone');
          if (phone != null) {
            _phoneController.text = phone.toString();
          }
          _dataLoaded = true;
        });

        // Mostrar mensaje de que se cargaron los datos
        final displayName = checkInPrevio['fullName'] ?? checkInPrevio['full_name'] ?? 'huésped';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Datos cargados de $displayName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ [CheckIn] Error buscando datos del huésped: $e');
      print('❌ [CheckIn] StackTrace: $stackTrace');
      debugPrint('Error buscando datos del huésped: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  /// Convierte fecha de YYYY-MM-DD a DD/MM/YYYY para mostrar
  String _formatDateForDisplay(String dateStr) {
    try {
      final parts = dateStr.split('T')[0].split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
      debugPrint('Error formateando fecha: $e');
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Check-in'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckInListScreen(),
                ),
              );
            },
            tooltip: 'Ver lista de check-ins',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Datos del huésped'),
                _buildDocumentField(),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Nombre completo',
                ),
                _buildTextField(
                  controller: _nationalityController,
                  label: 'Nacionalidad',
                ),
                _buildDateField(
                  controller: _birthDateController,
                  label: 'Fecha de nacimiento',
                  firstDate: DateTime(1925),
                  lastDate: DateTime.now(),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Contacto'),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Reserva'),
                _buildTextField(
                  controller: _reservationNumberController,
                  label: 'Número de reserva',
                ),
                _buildDateField(
                  controller: _arrivalDateController,
                  label: 'Fecha de llegada',
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                ),
                _buildDateField(
                  controller: _departureDateController,
                  label: 'Fecha de salida',
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownSection(
                      title: 'Cantidad de huéspedes',
                      child: DropdownButtonFormField<int>(
                        value: _guestCount,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          6,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1}'),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _guestCount = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownSection(
                      title: 'Plan de comidas',
                      child: DropdownButtonFormField<String>(
                        value: _mealPlan,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Sólo desayuno',
                            child: Text('Sólo desayuno'),
                          ),
                          DropdownMenuItem(
                            value: 'Media pensión',
                            child: Text('Media pensión'),
                          ),
                          DropdownMenuItem(
                            value: 'Pensión completa',
                            child: Text('Pensión completa'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _mealPlan = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Motivo del viaje',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _travelPurpose,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Turismo', child: Text('Turismo')),
                    DropdownMenuItem(
                      value: 'Negocios',
                      child: Text('Negocios'),
                    ),
                    DropdownMenuItem(value: 'Evento', child: Text('Evento')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _travelPurpose = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _vehicleDataController,
                  label: 'Datos del vehículo (opcional)',
                  isOptional: true,
                ),
                _buildTextField(
                  controller: _specialRequestsController,
                  label: 'Solicitudes especiales / alergias (opcional)',
                  maxLines: 3,
                  isOptional: true,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Registrar'),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeclarationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Ver declaraciones y condiciones'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Campo de documento con búsqueda automática de datos previos
  Widget _buildDocumentField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _documentController,
        focusNode: _documentFocusNode,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Completa este campo';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Documento / Pasaporte',
          border: const OutlineInputBorder(),
          helperText: 'Ingresa tu documento para cargar datos previos',
          suffixIcon: _isLoadingData
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar datos previos',
                  onPressed: () {
                    final documento = _documentController.text.trim();
                    if (documento.isNotEmpty) {
                      _buscarDatosHuesped(documento);
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: isOptional
            ? null
            : (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Completa este campo';
                }
                return null;
              },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Selecciona una fecha';
          }
          return null;
        },
        onTap: () => _pickDate(
          controller: controller,
          firstDate: firstDate,
          lastDate: lastDate,
        ),
      ),
    );
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
      lastDate: lastDate ?? now.add(const Duration(days: 365)),
      locale: Localizations.localeOf(context),
    );

    if (pickedDate != null) {
      controller.text =
          '${pickedDate.day.toString().padLeft(2, '0')}/'
          '${pickedDate.month.toString().padLeft(2, '0')}/'
          '${pickedDate.year}';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mostrar indicador de carga
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Convertir fechas de DD/MM/YYYY a YYYY-MM-DD
      final birthDate = _parseDate(_birthDateController.text);
      final arrivalDate = _parseDate(_arrivalDateController.text);
      final departureDate = _parseDate(_departureDateController.text);

      final checkInData = {
        'fullName': _fullNameController.text.trim(),
        'document': _documentController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'birthDate': birthDate,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'reservationNumber': _reservationNumberController.text.trim(),
        'arrivalDate': arrivalDate,
        'departureDate': departureDate,
        'guestCount': _guestCount,
        'mealPlan': _mealPlan,
        'travelPurpose': _travelPurpose,
        'vehicleData': _vehicleDataController.text.trim().isEmpty
            ? null
            : _vehicleDataController.text.trim(),
        'specialRequests': _specialRequestsController.text.trim().isEmpty
            ? null
            : _specialRequestsController.text.trim(),
      };

      final result = await ApiService.registrarCheckIn(checkInData);

      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Guardar documento y nombre completo en almacenamiento local si el check-in fue exitoso
      if (result['success']) {
        try {
          final document = _documentController.text.trim();
          final fullName = _fullNameController.text.trim();
          print('📝 CheckIn: Intentando guardar documento: $document');
          print('📝 CheckIn: Intentando guardar nombre: $fullName');
          if (document.isNotEmpty) {
            await LocalStorage.saveDocument(document);
            print('✅ CheckIn: Documento guardado exitosamente');
          } else {
            print('⚠️ CheckIn: Documento vacío, no se guarda');
          }
          if (fullName.isNotEmpty) {
            await LocalStorage.saveFullName(fullName);
            print('✅ CheckIn: Nombre guardado exitosamente');
          } else {
            print('⚠️ CheckIn: Nombre vacío, no se guarda');
          }
          // Verificar que se guardó correctamente
          final savedDoc = LocalStorage.getDocument();
          final savedName = LocalStorage.getFullName();
          print('🔍 CheckIn: Verificación final - Documento guardado: $savedDoc');
          print('🔍 CheckIn: Verificación final - Nombre guardado: $savedName');
        } catch (e) {
          print('❌ CheckIn: Error guardando datos locales: $e');
          debugPrint('Error guardando datos locales: $e');
        }
      } else {
        print('❌ CheckIn: Check-in falló, no se guardan datos locales');
      }

      // Mostrar resultado
      if (mounted) {
        final fullName = _fullNameController.text.trim();
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(result['success'] ? '¡Éxito!' : 'Error'),
            content: Text(
              result['success']
                  ? 'Bienvenido $fullName\n\n${result['mensaje']}'
                  : result['mensaje'],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (result['success']) {
                    // Limpiar formulario si fue exitoso
                    _fullNameController.clear();
                    _documentController.clear();
                    _nationalityController.clear();
                    _birthDateController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                    _reservationNumberController.clear();
                    _arrivalDateController.clear();
                    _departureDateController.clear();
                    _vehicleDataController.clear();
                    _specialRequestsController.clear();
                    setState(() {
                      _guestCount = 1;
                      _mealPlan = 'Sólo desayuno';
                      _travelPurpose = 'Turismo';
                    });
                    // Volver al HomeScreen para que se actualice y muestre todas las funciones
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error inesperado: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  String _parseDate(String dateStr) {
    // Convierte DD/MM/YYYY a YYYY-MM-DD
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dateStr;
  }
}
