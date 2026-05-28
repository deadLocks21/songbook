import 'package:dio/dio.dart';
import 'package:songbook/core/application/dtos/remote_song.dto.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/core/utils/backend_endpoints.dart';
import 'package:songbook/core/utils/backend_url.dart';

/// Implémentation du RemoteSongRepository utilisant Dio pour les requêtes HTTP.
class DioRemoteSongRepository implements RemoteSongRepository {
  final Dio _dio;

  /// Plafond dur sur la requête. Les timeouts de Dio ne couvrent pas le cas
  /// « connexion TCP ouverte mais aucune réponse » (ex. port de conteneur relayé
  /// qui accepte la connexion puis reste muet) : `connectTimeout` est déjà
  /// satisfait et `receiveTimeout` ne s'arme qu'entre deux octets reçus. Sans ce
  /// plafond, la requête pendrait indéfiniment et la sync ne se terminerait jamais.
  final Duration _requestTimeout;

  DioRemoteSongRepository(
    this._dio, {
    Duration requestTimeout = const Duration(seconds: 90),
  }) : _requestTimeout = requestTimeout;

  @override
  Future<List<RemoteSong>> fetchSongs(
    String baseUrl, {
    List<String> recueils = const [],
  }) async {
    // [baseUrl] est l'origine (domaine) ; le chemin de l'API est ajouté ici.
    final url = BackendUrl.join(baseUrl, BackendEndpoints.songs);
    final queryParameters = recueils.isEmpty
        ? null
        : <String, dynamic>{'recueils': recueils.join(',')};
    final response = await _dio
        .get<Map<String, dynamic>>(url, queryParameters: queryParameters)
        .timeout(
          _requestTimeout,
          onTimeout: () => throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.receiveTimeout,
          ),
        );
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
