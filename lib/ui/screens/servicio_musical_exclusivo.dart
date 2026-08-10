import 'package:http/http.dart' as http;
import 'dart:convert';

class DriveSong {
  final String title;
  final String streamUrl;

  DriveSong({required this.title, required this.streamUrl});

  factory DriveSong.fromJson(Map<String, dynamic> json) {
    return DriveSong(
      title: json['title'] ?? json['name'] ?? 'Sin título',
      streamUrl: json['streamUrl'] ?? json['webContentLink'] ?? json['url'] ?? '',
    );
  }
}

class ExclusiveMusicService {
  static Future<List<DriveSong>> fetchExclusiveSongs() async {
    try {
      final response = await http.get(
        Uri.parse('http://128.254.190.44:3000/api/drive/music'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> songsList = data['songs'] ?? [];
        return songsList.map((dynamic item) => DriveSong.fromJson(item)).toList();
      }
    } catch (e) {
      // Manejo de error silencioso
    }
    return [];
  }
}
