import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://apisocial.vistasouth.com.ar:3000/api';

  static Future<List<Map<String, dynamic>>> obtenerCanchasDisponibles(
    int idClub,
    int idDeporte,
  ) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/canchas/$idClub'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al obtener canchas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener canchas: $e');
    }
  }

  Future<List<dynamic>> obtenerTurnosDisponiblesPorCancha(
    int? canchaId,
    String fecha,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/turnos-disponibles/$canchaId/$fecha'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener turnos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener turnos: $e');
    }
  }

  static Future<List<dynamic>> obtenerReservas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reservas'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener reservas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener reservas: $e');
    }
  }

  static Future<List<dynamic>> obtenerReservasPorDNI(String dni) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reservas/$dni'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener reservas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener reservas: $e');
    }
  }

  static Future<bool> crearReserva(Map<String, dynamic> reservaData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reservaData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al crear reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear reserva: $e');
    }
  }

  static Future<Map<String, dynamic>> registrarCheckIn(
    Map<String, dynamic> checkInData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hotel-yacanto/checkin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(checkInData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? 'Check-in registrado correctamente',
        };
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {
          'success': false,
          'mensaje': data['mensaje'] ?? 'Error en los datos enviados',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'mensaje': data['mensaje'] ?? 'Error al registrar el check-in',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> registrarReservaRestaurante(
    Map<String, dynamic> reservaData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hotel-yacanto/restaurante/reservas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reservaData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? 'Reserva de restaurante registrada',
        };
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {
          'success': false,
          'mensaje': data['mensaje'] ?? 'Error en los datos enviados',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'mensaje': data['mensaje'] ?? 'Error al registrar la reserva',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  static Future<List<dynamic>> obtenerCheckIns() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hotel-yacanto/checkin'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener check-ins: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener check-ins: $e');
    }
  }

  /// Busca un check-in previo por documento para autocompletar datos personales
  static Future<Map<String, dynamic>?> buscarCheckInPorDocumento(
    String documento,
  ) async {
    final url = '$baseUrl/hotel-yacanto/checkin/$documento';
    print('🌐 [API] GET $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
      );

      print('🌐 [API] Status code: ${response.statusCode}');
      print('🌐 [API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🌐 [API] Datos decodificados: $data');
        print('🌐 [API] Tipo de datos: ${data.runtimeType}');
        
        // La API puede devolver un objeto directamente o una lista
        if (data is List && data.isNotEmpty) {
          print('🌐 [API] La respuesta es una lista, tomando primer elemento');
          return data[0] as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          return data;
        } else {
          print('⚠️ [API] Formato de respuesta no esperado: ${data.runtimeType}');
          return null;
        }
      } else if (response.statusCode == 404) {
        // No se encontró check-in previo, es normal
        print('🌐 [API] 404 - No se encontró check-in previo');
        return null;
      } else {
        print('⚠️ [API] Error status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Error de conexión, no interrumpir el flujo
      print('❌ [API] Error de conexión: $e');
      debugPrint('Error buscando check-in por documento: $e');
      return null;
    }
  }

  static Future<List<dynamic>> obtenerReservasRestaurante() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hotel-yacanto/restaurante/reservas'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
          'Error al obtener reservas de restaurante: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener reservas de restaurante: $e');
    }
  }

  static Future<Map<String, dynamic>> obtenerHabitacionPorDocumento(
    String documento,
  ) async {
    try {
      // Construir URL con query parameters
      final uri = Uri.parse('$baseUrl/hotel-yacanto/habitaciones/registro')
          .replace(queryParameters: {
        'document': documento,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'hasRoom': false,
          'mensaje': 'No tiene habitación asignada',
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'mensaje': data['mensaje'] ?? 'Error al obtener la habitación',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // MercadoPago deshabilitado temporalmente
  // static Future<bool> clubTieneMercadoPago(int idClub) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/clubs/$idClub/mercadopago'),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return data['tiene_mercadopago'] ?? false;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<Map<String, dynamic>> crearPreferencia({
  //   required String reservaId,
  //   required double precio,
  //   required String nombreCancha,
  //   required String fecha,
  //   required String hora,
  //   required String nombreCompleto,
  //   required String email,
  //   required String dni,
  //   required String telefono,
  //   required int idClub,
  //   required String tipoServicio,
  //   required String descripcionServicio,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/mercadopago/preferencia'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'reserva_id': reservaId,
  //         'precio': precio,
  //         'nombre_cancha': nombreCancha,
  //         'fecha': fecha,
  //         'hora': hora,
  //         'nombre_completo': nombreCompleto,
  //         'email': email,
  //         'dni': dni,
  //         'telefono': telefono,
  //         'id_club': idClub,
  //         'tipo_servicio': tipoServicio,
  //         'descripcion_servicio': descripcionServicio,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       return {'success': false, 'error': 'Error al crear preferencia'};
  //     }
  //   } catch (e) {
  //     return {'success': false, 'error': e.toString()};
  //   }
  // }
}
