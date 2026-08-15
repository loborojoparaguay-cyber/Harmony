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
  String _hlCode = "en";

  @override
  void onInit() {
    printINFO("🚀 MusicServices inicializado apuntando a tu servidor central");
    super.onInit();
  }

  set hlCode(String code) {
    _hlCode = code;
  }

  String get hlCode => _hlCode;

  // --- 1. CARGA DEL INICIO (Llena el home aprovechando el buscador de tu servidor) ---
  Future<List<dynamic>> getHome({int limit = 4}) async {
    try {
      final response = await dio.get(
        '${RemoteConfigService.baseUrl}/api/search',
        queryParameters: {'q': 'exitos musicales del momento'},
      );
      
      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        final songs = data.map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Desconocido',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
        )).toList();

        // Estructura requerida en formato de sección para la pantalla principal
        return [
          {
            'title': 'Lo más sonado',
            'contents': songs,
          }
        ];
      }
    } catch (e) {
      printERROR("Error al cargar el inicio: $e");
    }
    return [];
  }

  // --- 2. CHARTS ---
  Future<List<Map<String, dynamic>>> getCharts(String category, {String? countryCode}) async {
    return [];
  }

  // --- 3. CONTENIDO RELACIONADO ---
  Future<dynamic> getContentRelatedToSong(String videoId, String hlCode) async {
    try {
      final response = await dio.get(
        '${RemoteConfigService.baseUrl}/api/next',
        queryParameters: {'videoId': videoId},
      );
      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        return data.map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Desconocido',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
        )).toList();
      }
    } catch (e) {
      printERROR("Error en contenido relacionado: $e");
    }
    return [];
  }

  // --- 4. BÚSQUEDA ---
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
        final songs = data.map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Desconocido',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
          extras: {'resultType': 'song'},
        )).toList();

        return {'Songs': songs};
      }
    } catch (e) {
      printERROR("Error en búsqueda del servidor: $e");
    }
    return {};
  }

  // --- 5. COLA DE REPRODUCCIÓN / RADIO ---
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

  // --- 6. MÉTODOS REQUERIDOS POR PANTALLAS ---
  Future<Map<String, dynamic>> getArtistRealtedContent(
      Map<String, dynamic> browseEndpoint, String category,
      {String additionalParams = ""}) async {
    return {"results": [], "additionalParams": ""};
  }

  Future<Map<String, dynamic>> getSearchContinuation(Map additionalParamsNext,
      {int limit = 10}) async {
    return {};
  }

  // --- 7. MÉTODOS AUXILIARES ---
  Future<List<String>> getSearchSuggestion(String queryStr) async => [];

  Future<List> getSongWithId(String songId) async {
    final list = await getWatchPlaylist(videoId: songId);
    return ((list['tracks'] as List).isNotEmpty) ? [true, list['tracks']] : [false, null];
  }

  Future<Map<String, dynamic>> getArtist(String channelId) async => 
      {'name': 'Artista', 'description': '', 'thumbnails': []};

  Future<Map<String, dynamic>> getPlaylistOrAlbumSongs({String? playlistId, String? albumId}) async => 
      {'tracks': [], 'title': 'Playlist'};

  Future<String?> getSongYear(String songId) async => null;

  Future<dynamic> getLyrics(String browseId) async => null;

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}

class NetworkError extends Error {
  final message = "Network Error !";
}
