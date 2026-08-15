// ignore_for_file: constant_identifier_names

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'remote_config_service.dart';
import '../utils/helper.dart'; // Asegúrate de que esta ruta sea la correcta en tu proyecto

class MusicServices extends getx.GetxService {
  final dio = Dio();

  @override
  void onInit() {
    printINFO("🚀 MusicServices inicializado apuntando a tu servidor central");
    super.onInit();
  }

  // --- 1. CARGA DEL INICIO (Carga tus músicas exclusivas en el Home) ---
  Future<List<dynamic>> getHome() async {
    try {
      final response = await dio.get('${RemoteConfigService.baseUrl}/api/drive/music');
      if (response.statusCode == 200) {
        final data = response.data;
        // Convertimos el JSON a una lista de canciones
        final songs = (data['songs'] as List).map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Música Exclusiva',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
        )).toList();
        return songs;
      }
    } catch (e) {
      printERROR("Error al cargar el inicio: $e");
    }
    return [];
  }

  // --- 2. BÚSQUEDA (Consulta a tu servidor con youtubei.js) ---
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

  // --- 3. COLA DE REPRODUCCIÓN / RADIO ---
  Future<Map<String, dynamic>> getWatchPlaylist(
      {String videoId = "",
      String? playlistId,
      int limit = 25,
      bool radio = false,
      bool shuffle = false,
      String? additionalParamsNext,
      bool onlyRelated = false}) async {
    
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

  // Métodos necesarios para que la app no tire errores
  Future<List<String>> getSearchSuggestion(String queryStr) async => [];

  Future<List> getSongWithId(String songId) async {
    final list = await getWatchPlaylist(videoId: songId);
    return ((list['tracks'] as List).isNotEmpty) ? [true, list['tracks']] : [false, null];
  }

  Future<Map<String, dynamic>> getArtist(String channelId) async => 
      {'name': 'Artista', 'description': '', 'thumbnails': []};

  Future<Map<String, dynamic>> getPlaylistOrAlbumSongs({String? playlistId, String? albumId}) async => 
      {'tracks': [], 'title': 'Playlist'};

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}
