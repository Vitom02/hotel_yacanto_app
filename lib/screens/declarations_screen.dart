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
                  child: const SingleChildScrollView(
                    child: Text(
                      'Aquí podrás pegar el texto definitivo de las políticas, '
                      'declaraciones y términos que el huésped deberá aceptar. '
                      'Puedes reemplazar este texto con el material que te '
                      'comparta el equipo legal o de administración. '
                      '\n\nEjemplo de contenido sugerido:\n'
                      '- Autorización de uso de datos personales.\n'
                      '- Responsabilidad por objetos de valor.\n'
                      '- Políticas de cancelación y horarios.\n'
                      '- Normas de convivencia e instalaciones.\n'
                      '- Declaración sanitaria o de alergias.\n'
                      '\nCuando recibas el texto oficial, simplemente\n'
                      'actualiza este bloque para mostrarlo al personal '
                      'y que el huésped pueda leerlo antes de firmar.',
                      style: TextStyle(fontSize: 16, height: 1.4),
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
}
