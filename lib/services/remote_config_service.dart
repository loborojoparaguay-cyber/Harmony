import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteConfigService {
  // Instancias por defecto
  static String pipedInstance = 'https://piped.kavin.rocks';
  static bool isMaintenance = false;

  // 🔥 AQUÍ DEFINÍS TU API CENTRAL (Ahora con HTTPS y sin el puerto 3000 gracias a Cloudflare)
  static const String baseUrl = 'https://music.loborojo.store';

  static const String _configUrl = '$baseUrl/api/config';

  /// Llama al servidor para traer la configuración actualizada
  static static Future<void> init() async {
    try {
      final response = await http.get(Uri.parse(_configUrl)).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data.containsKey('piped_instance') && data['piped_instance'] != null) {
          pipedInstance = data['piped_instance'];
        }
        
        if (data.containsKey('maintenance_mode') && data['maintenance_mode'] != null) {
          isMaintenance = data['maintenance_mode'];
        }

        print('✅ Remote Config cargado correctamente');
      }
    } catch (e) {
      print('⚠️ Usando valores por defecto: $e');
    }
  }
}
