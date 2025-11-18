import 'package:flutter/material.dart';
import 'tennis_turnos_screen.dart';
// import '../session/user_session.dart';

class TennisScreen extends StatelessWidget {
  const TennisScreen({super.key});

  static const int idClub = 9;
  static const int idDeporte = 1;
  static const String dni = '1232131';
  static const String nombrecompleto = 'UsuarioTest';

  @override
  Widget build(BuildContext context) {
    final nombre = nombrecompleto;

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
                      idClub: idClub,
                      idDeporte: idDeporte,
                      dni: dni,
                      nombrecompleto: nombrecompleto,
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

