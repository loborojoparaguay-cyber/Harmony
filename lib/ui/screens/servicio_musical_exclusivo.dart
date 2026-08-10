
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriveSong {
  final String title;
  final String streamUrl;

  DriveSong({required this.title, required this.streamUrl});

  factory DriveSong.fromJson(Map<String, dynamic> json) {
    return DriveSong(
      title: json['title'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
    );
  }
}

class ExclusiveMusicService {
  static Future<List<DriveSong>> fetchExclusiveSongs() async {
    // Reemplaza con la URL o IP de tu VPS si es necesario
    try {
      final response = await http.get(Uri.parse('http://128.254.190.44:3000/api/musica'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => DriveSong.fromJson(item)).toList();
      }
    } catch (e) {
      // Manejo de error
    }
    return [];
  }
}
