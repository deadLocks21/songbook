import 'package:dio/dio.dart';
import 'package:songbook/core/application/dtos/remote_song.dto.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';

/// Implémentation du RemoteSongRepository utilisant Dio pour les requêtes HTTP.
class DioRemoteSongRepository implements RemoteSongRepository {
  final Dio _dio;

  DioRemoteSongRepository(this._dio);

  @override
  Future<List<RemoteSong>> fetchSongs(String baseUrl) async {
    final response = await _dio.get<Map<String, dynamic>>(baseUrl);
    final responseData = response.data;

    if (responseData == null) {
      return [];
    }

    final jsonList = responseData['data'] as List<dynamic>?;

    if (jsonList == null) {
      return [];
    }

    return jsonList
        .map(
          (json) =>
              RemoteSongDto.fromJson(json as Map<String, dynamic>).toDomain(),
        )
        .toList();
  }
}
