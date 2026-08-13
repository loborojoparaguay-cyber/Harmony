import 'package:http/http.dart' as http;
import 'dart:convert';

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
      streamUrl: 'https://music.loborojo.store/api/drive/stream/$fileId',
    );
  }
}

class ExclusiveMusicService {
  static Future<List<DriveSong>> fetchExclusiveSongs() async {
    try {
      final response = await http.get(
        Uri.parse('https://music.loborojo.store/api/drive/music'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> songsList = data['songs'] ?? [];
        return songsList.map((dynamic item) => DriveSong.fromJson(item)).toList();
      }
    } catch (e) {
      // Error de red
    }
    return [];
  }
}
