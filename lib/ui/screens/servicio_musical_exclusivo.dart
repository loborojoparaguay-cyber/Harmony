import 'package:http/http.dart' as http;
import 'dart:convert';
import 'remote_config_service.dart';

class DriveSong {
  final String id;
  final String title;
  final String folderName;
  final String streamUrl;

  DriveSong({
    required this.id,
    required this.title,
    required this.folderName,
    required this.streamUrl,
  });

  factory DriveSong.fromJson(Map<String, dynamic> json) {
    final fileId = json['id'] ?? '';
    return DriveSong(
      id: fileId,
      title: json['title'] ?? json['name'] ?? 'Sin título',
      folderName: json['folderName'] ?? json['album'] ?? 'Carpeta Principal',
      // Usamos la URL base centralizada
      streamUrl: '${RemoteConfigService.baseUrl}/api/drive/stream/$fileId',
    );
  }
}

class ExclusiveMusicService {
  static Future<List<DriveSong>> fetchExclusiveSongs() async {
    try {
      final response = await http.get(
        Uri.parse('${RemoteConfigService.baseUrl}/api/drive/music'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> songsList = data['songs'] ?? [];
        return songsList.map((dynamic item) => DriveSong.fromJson(item)).toList();
      } else {
        print("Error del servidor/Cloudflare: Código ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
    return [];
  }
}
