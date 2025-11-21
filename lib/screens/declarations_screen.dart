import 'package:flutter/material.dart';

class DeclarationsScreen extends StatelessWidget {
  const DeclarationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Declaraciones y condiciones')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Declaraciones',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DECLARACIONES Y CONDICIONES DEL HOTEL YACANTO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '1. AUTORIZACIÓN DE USO DE DATOS PERSONALES',
                          'El huésped autoriza al Hotel Yacanto a utilizar sus datos personales para fines administrativos, de reserva, facturación y comunicación relacionada con su estadía, de acuerdo con la normativa vigente en materia de protección de datos.',
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '2. RESPONSABILIDAD POR OBJETOS DE VALOR',
                          'El hotel no se responsabiliza por objetos de valor, dinero en efectivo, documentos o pertenencias personales dejados en las habitaciones. Se recomienda utilizar la caja fuerte disponible en recepción para guardar objetos de valor.',
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '3. POLÍTICAS DE CANCELACIÓN Y HORARIOS',
                          'Check-in: a partir de las 15:00 hs.\nCheck-out: hasta las 11:00 hs.\nLas cancelaciones deben realizarse con 48 horas de anticipación para evitar cargos adicionales. Cancelaciones con menos de 48 horas estarán sujetas a penalización según las políticas vigentes.',
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '4. NORMAS DE CONVIVENCIA E INSTALACIONES',
                          'Se solicita respetar el horario de descanso (22:00 - 08:00 hs), mantener el orden en las instalaciones comunes, hacer uso responsable de los servicios del hotel y respetar a otros huéspedes y al personal del establecimiento.',
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '5. DECLARACIÓN SANITARIA Y ALERGIAS',
                          'El huésped declara que no padece enfermedades contagiosas y se compromete a comunicar cualquier alergia o condición médica relevante para su estadía, especialmente relacionadas con alimentos o productos de limpieza utilizados en el hotel.',
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '6. USO DE INSTALACIONES',
                          'El uso de las instalaciones deportivas (tenis, piscina), del restaurante y otros servicios está sujeto a disponibilidad y reserva previa. El hotel se reserva el derecho de modificar horarios y disponibilidad según necesidades operativas.',
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '7. FACTURACIÓN Y PAGOS',
                          'Todos los consumos adicionales serán facturados al momento del check-out. Se aceptan efectivo y tarjetas de crédito/débito. El hotel se reserva el derecho de solicitar depósito o garantía según corresponda.',
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          '8. PROHIBICIONES',
                          'Queda prohibido fumar en áreas cerradas, causar disturbios, introducir mascotas sin autorización previa, y cualquier actividad que pueda perturbar la tranquilidad de otros huéspedes o dañar las instalaciones.',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Al completar el check-in, el huésped acepta estas condiciones en su totalidad y se compromete a cumplirlas durante toda su estadía.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver al formulario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }
}
