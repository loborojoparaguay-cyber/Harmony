import 'dart:convert';
import 'package:http/http.dart' as http;

class DriveSong {
  final String id;
  final String title;
  final String streamUrl;

  DriveSong({
    required this.id,
    required this.title,
    required this.streamUrl,
  });

  factory DriveSong.fromJson(Map<String, dynamic> json) {
    return DriveSong(
      id: json['id'],
      title: json['title'],
      streamUrl: json['streamUrl'],
    );
  }
}

class ExclusiveMusicService {
  // Conexión directa con tu VPS
  static const String baseUrl = 'http://music.loborojo.store:3000/api/drive/music';


  static Future<List<DriveSong>> fetchExclusiveSongs() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List songsList = data['songs'] ?? [];
        return songsList.map((json) => DriveSong.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error obteniendo canciones del VPS: $e");
    }
    return [];
  }
}
