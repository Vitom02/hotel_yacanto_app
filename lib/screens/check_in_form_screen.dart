import 'package:flutter/material.dart';

import '../services/apiconnect.dart';
import 'check_in_list_screen.dart';
import 'declarations_screen.dart';

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

  String _mealPlan = 'Sólo desayuno';
  String _travelPurpose = 'Turismo';
  int _guestCount = 1;

  @override
  void dispose() {
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
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Nombre completo',
                ),
                _buildTextField(
                  controller: _documentController,
                  label: 'Documento / Pasaporte',
                ),
                _buildTextField(
                  controller: _nationalityController,
                  label: 'Nacionalidad',
                ),
                _buildDateField(
                  controller: _birthDateController,
                  label: 'Fecha de nacimiento',
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
                ),
                _buildTextField(
                  controller: _specialRequestsController,
                  label: 'Solicitudes especiales / alergias',
                  maxLines: 3,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
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

      // Mostrar resultado
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result['success'] ? 'Éxito' : 'Error'),
            content: Text(result['mensaje']),
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
