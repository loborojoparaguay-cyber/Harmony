// ignore_for_file: constant_identifier_names

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'remote_config_service.dart';
import '../utils/helper.dart';

enum AudioQuality { Low, High }

class MusicServices extends getx.GetxService {
  final dio = Dio();
  String _hlCode = "en";

  @override
  void onInit() {
    printINFO("🚀 MusicServices apuntando al servidor central");
    super.onInit();
  }

  set hlCode(String code) => _hlCode = code;
  String get hlCode => _hlCode;

  // --- 1. CARGA DEL INICIO ---
  Future<List<dynamic>> getHome({int limit = 4}) async {
    try {
      final response = await dio.get('${RemoteConfigService.baseUrl}/api/home');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((section) {
          return {
            'title': section['title'] ?? 'Recomendaciones',
            'contents': (section['contents'] as List).map((item) => MediaItem(
              id: item['videoId'] ?? item['id'] ?? '',
              title: item['title'] ?? 'Sin título',
              artist: item['artist'] ?? 'Desconocido',
              artUri: Uri.parse(item['thumbnail'] ?? ''),
            )).toList(),
          };
        }).toList();
      }
    } catch (e) { printERROR("Error Home: $e"); }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCharts(String category, {String? countryCode}) async => [];

  // --- 3. CONTENIDO RELACIONADO ---
  Future<dynamic> getContentRelatedToSong(String videoId, String hlCode) async {
    return (await getWatchPlaylist(videoId: videoId))['tracks'];
  }

  // --- 4. BÚSQUEDA ---
  Future<Map<String, dynamic>> search(String query, {String? filter, String? scope, int limit = 30, bool ignoreSpelling = false, String? filterParams}) async {
    try {
      final response = await dio.get('${RemoteConfigService.baseUrl}/api/search', queryParameters: {'q': query});
      if (response.statusCode == 200 && response.data is List) {
        return {'Songs': (response.data as List).map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Desconocido',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
          extras: {'resultType': 'song'},
        )).toList()};
      }
    } catch (e) {}
    return {};
  }

  // --- 5. COLA DE REPRODUCCIÓN / RADIO OPTIMIZADA ---
  Future<Map<String, dynamic>> getWatchPlaylist({String videoId = "", String? playlistId, int limit = 25, bool radio = false, bool shuffle = false, String? additionalParamsNext, bool onlyRelated = false}) async {
    
    // Si no hay videoId pero hay playlistId (modo continuación de radio), lo extraemos
    String targetId = videoId;
    if (targetId.isEmpty && playlistId != null) {
       targetId = playlistId.replaceAll('RDAMVM', '').replaceAll('RD', '');
    }
    if (targetId.startsWith("MPED")) targetId = targetId.substring(4);

    try {
      final response = await dio.get(
        '${RemoteConfigService.baseUrl}/api/next',
        queryParameters: {
          'videoId': targetId,
          'radio': radio.toString() // Le avisa al servidor que queremos un MIX
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final tracks = (response.data as List).map((item) => MediaItem(
          id: item['videoId'] ?? item['id'] ?? '',
          title: item['title'] ?? 'Sin título',
          artist: item['artist'] ?? 'Desconocido',
          artUri: Uri.parse(item['thumbnail'] ?? ''),
        )).toList();

        return {
          'tracks': tracks,
          'playlistId': playlistId ?? 'RDAMVM$targetId',
          'lyrics': null,
          'related': null,
          'additionalParamsForNext': null
        };
      }
    } catch (e) { printERROR("Error Playlist: $e"); }
    return {'tracks': [], 'playlistId': playlistId};
  }

  // --- MÉTODOS AUXILIARES ---
  Future<Map<String, dynamic>> getArtistRealtedContent(Map<String, dynamic> browseEndpoint, String category, {String additionalParams = ""}) async => {"results": [], "additionalParams": ""};
  Future<Map<String, dynamic>> getSearchContinuation(Map additionalParamsNext, {int limit = 10}) async => {};
  Future<List<String>> getSearchSuggestion(String queryStr) async => [];
  Future<List> getSongWithId(String songId) async {
    final list = await getWatchPlaylist(videoId: songId);
    return ((list['tracks'] as List).isNotEmpty) ? [true, list['tracks']] : [false, null];
  }
  Future<Map<String, dynamic>> getArtist(String channelId) async => {'name': 'Artista', 'description': '', 'thumbnails': []};
  Future<Map<String, dynamic>> getPlaylistOrAlbumSongs({String? playlistId, String? albumId}) async => {'tracks': [], 'title': 'Playlist'};
  Future<String?> getSongYear(String songId) async => null;
  Future<dynamic> getLyrics(String browseId) async => null;

  @override
  void onClose() {
    dio.close();
    super.onClose();
  }
}
class NetworkError extends Error { final message = "Network Error !"; }
