import 'package:dio/dio.dart';
import 'package:songbook/core/application/dtos/recueil.dto.dart';
import 'package:songbook/core/domain/model/recueil.dart';
import 'package:songbook/core/domain/services/remote_recueil.repository.dart';
import 'package:songbook/core/utils/backend_endpoints.dart';
import 'package:songbook/core/utils/backend_url.dart';

/// Implémentation du [RemoteRecueilRepository] utilisant Dio.
class DioRemoteRecueilRepository implements RemoteRecueilRepository {
  final Dio _dio;

  /// Cf. [DioRemoteSongRepository] : plafond dur pour éviter qu'une connexion
  /// ouverte mais muette ne fasse pendre la requête indéfiniment.
  final Duration _requestTimeout;

  DioRemoteRecueilRepository(
    this._dio, {
    Duration requestTimeout = const Duration(seconds: 90),
  }) : _requestTimeout = requestTimeout;

  @override
  Future<List<Recueil>> fetchRecueils(String baseUrl) async {
    final url = BackendUrl.join(baseUrl, BackendEndpoints.recueils);
    final response = await _dio.get<Map<String, dynamic>>(url).timeout(
          _requestTimeout,
          onTimeout: () => throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.receiveTimeout,
          ),
        );

    final jsonList = response.data?['data'] as List<dynamic>?;
    if (jsonList == null) {
      return [];
    }

    return jsonList
        .map(
          (json) =>
              RecueilDto.fromJson(json as Map<String, dynamic>).toDomain(),
        )
        .toList();
  }
}
