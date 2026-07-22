import 'package:dio/dio.dart';
import 'package:songbook/core/application/dtos/remote_song_list.dto.dart';
import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/core/utils/backend_endpoints.dart';
import 'package:songbook/core/utils/backend_url.dart';

/// Implémentation du RemoteSongListRepository utilisant Dio.
class DioRemoteSongListRepository implements RemoteSongListRepository {
  final Dio _dio;

  /// Même plafond dur que pour le catalogue : les timeouts de Dio ne couvrent
  /// pas le cas « connexion acceptée mais serveur muet », qui ferait pendre la
  /// synchro indéfiniment (cf. [DioRemoteSongRepository]).
  final Duration _requestTimeout;

  DioRemoteSongListRepository(
    this._dio, {
    Duration requestTimeout = const Duration(seconds: 30),
  }) : _requestTimeout = requestTimeout;

  @override
  Future<SongListSnapshot> fetchAll(String baseUrl) async {
    final url = BackendUrl.join(baseUrl, BackendEndpoints.songLists);
    final response = await _send(
      () => _dio.get<Map<String, dynamic>>(url),
      url,
    );

    final data = response.data;
    if (data == null) {
      return const SongListSnapshot(lists: [], deletedIds: []);
    }

    final lists = (data['data'] as List<dynamic>? ?? const [])
        .map(
          (json) => RemoteSongListDto.fromJson(
            json as Map<String, dynamic>,
          ).toDomain(),
        )
        .toList();

    final deletedIds = (data['deleted'] as List<dynamic>? ?? const [])
        .map((id) => UuidValue.parse(id as String))
        .toList();

    return SongListSnapshot(lists: lists, deletedIds: deletedIds);
  }

  @override
  Future<int> create(String baseUrl, SongList songList) async {
    final url = BackendUrl.join(baseUrl, BackendEndpoints.songLists);
    final response = await _send(
      () => _dio.post<Map<String, dynamic>>(
        url,
        data: RemoteSongListDto.writePayload(songList),
      ),
      url,
    );

    return _versionOf(response, url);
  }

  @override
  Future<int> update(String baseUrl, SongList songList) async {
    final baseVersion = songList.version;
    if (baseVersion == null) {
      throw ArgumentError(
        'Impossible de mettre à jour une liste jamais poussée : utilisez create.',
      );
    }

    final url = BackendUrl.join(
      baseUrl,
      '${BackendEndpoints.songLists}/${songList.id.value}',
    );

    try {
      final response = await _send(
        () => _dio.patch<Map<String, dynamic>>(
          url,
          data: RemoteSongListDto.writePayload(
            songList,
            baseVersion: baseVersion,
          ),
        ),
        url,
      );

      return _versionOf(response, url);
    } on DioException catch (e) {
      final conflict = _asVersionConflict(e);
      if (conflict != null) throw conflict;
      // Supprimée depuis un autre appareil : l'appelant décide quoi en faire
      // (la renvoyer comme une création plutôt que perdre l'édition locale).
      if (e.response?.statusCode == 404) throw const SongListGoneException();
      rethrow;
    }
  }

  @override
  Future<void> delete(String baseUrl, UuidValue id) async {
    final url = BackendUrl.join(
      baseUrl,
      '${BackendEndpoints.songLists}/${id.value}',
    );

    try {
      await _send(() => _dio.delete<void>(url), url);
    } on DioException catch (e) {
      // Déjà absente côté serveur : le but est atteint, pas de quoi bloquer la
      // synchro. La ligne locale sera purgée comme après une vraie suppression.
      if (e.response?.statusCode == 404) return;
      rethrow;
    }
  }

  /// Traduit un `409 version_conflict` en exception métier, en récupérant la
  /// version courante annoncée par le serveur.
  SongListVersionConflictException? _asVersionConflict(DioException e) {
    if (e.response?.statusCode != 409) return null;

    final data = e.response?.data;
    if (data is! Map || data['code'] != 'version_conflict') return null;

    final currentVersion = data['currentVersion'];
    return currentVersion is int
        ? SongListVersionConflictException(currentVersion)
        : null;
  }

  int _versionOf(Response<Map<String, dynamic>> response, String url) {
    final version = response.data?['version'];
    if (version is! int) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.badResponse,
        error: 'Réponse sans version exploitable',
      );
    }
    return version;
  }

  Future<Response<T>> _send<T>(
    Future<Response<T>> Function() request,
    String url,
  ) {
    return request().timeout(
      _requestTimeout,
      onTimeout: () => throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.receiveTimeout,
      ),
    );
  }
}
