// ignore_for_file: constant_identifier_names

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'remote_config_service.dart';
import '../utils/helper.dart';

enum AudioQuality {
  Low,
  High,
}

class MusicServices extends getx.GetxService {
  final dio = Dio();

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    printINFO("🚀 MusicServices inicializado apuntando a tu servidor central");
  }

  // --- BÚSQUEDA GESTIONADA POR TU SERVIDOR (youtubei.js) ---
  Future<Map<String, dynamic>> search(String query,
      {String? filter,
      String? scope,
      int limit = 30,
      bool ignoreSpelling = false,
      String? filterParams}) async {
    try {
      final response = await dio.get(
        '${RemoteConfigService.baseUrl}/api/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        
        // Convertimos la respuesta de tu servidor al formato que la app espera
        final songs = data.map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Desconocido',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
          extras: {
            'resultType': 'song',
          },
        )).toList();

        return {
          'Songs': songs,
        };
      }
    } catch (e) {
      printERROR("Error en búsqueda del servidor: $e");
    }
    return {};
  }

  // --- COLA DE REPRODUCCIÓN / RADIO / RELACIONADOS GESTIONADA POR TU SERVIDOR ---
  Future<Map<String, dynamic>> getWatchPlaylist(
      {String videoId = "",
      String? playlistId,
      int limit = 25,
      bool radio = false,
      bool shuffle = false,
      String? additionalParamsNext,
      bool onlyRelated = false}) async {
    
    if (videoId.isNotEmpty && videoId.substring(0, 4) == "MPED") {
      videoId = videoId.substring(4);
    }

    try {
      final response = await dio.get(
        '${RemoteConfigService.baseUrl}/api/next',
        queryParameters: {'videoId': videoId},
      );

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        
        final tracks = data.map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Desconocido',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
        )).toList();

        return {
          'tracks': tracks,
          'playlistId': playlistId ?? 'server_queue',
          'lyrics': null,
          'related': null,
          'additionalParamsForNext': null
        };
      }
    } catch (e) {
      printERROR("Error al obtener cola del servidor: $e");
    }

    return {
      'tracks': [],
      'playlistId': playlistId,
      'lyrics': null,
      'related': null,
      'additionalParamsForNext': null
    };
  }

  // Métodos de soporte auxiliares requeridos por la estructura de la app
  Future<List<String>> getSearchSuggestion(String queryStr) async {
    return [];
  }

  Future<List> getSongWithId(String songId) async {
    final list = await getWatchPlaylist(videoId: songId);
    if ((list['tracks'] as List).isNotEmpty) {
      return [true, list['tracks']];
    }
    return [false, null];
  }

  Future<Map<String, dynamic>> getArtist(String channelId) async {
    return {'name': 'Artista', 'description': '', 'thumbnails': []};
  }

  Future<Map<String, dynamic>> getPlaylistOrAlbumSongs(
      {String? playlistId,
      String? albumId,
      int limit = 3000,
      bool related = false,
      int suggestionsLimit = 0}) async {
    return {'tracks': [], 'title': 'Playlist'};
  }

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}

class NetworkError extends Error {
  final message = "Network Error !";
}
