import 'package:dio/dio.dart';
import 'package:songbook/core/application/dtos/remote_song_list.dto.dart';
import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/subscription_result.dart';
import 'package:songbook/core/domain/model/upstream_state.dart';
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

    final upstream = (data['upstream'] as List<dynamic>? ?? const [])
        .map((json) => _upstreamState(json as Map<String, dynamic>))
        .toList();

    return SongListSnapshot(
      lists: lists,
      deletedIds: deletedIds,
      upstream: upstream,
    );
  }

  UpstreamState _upstreamState(Map<String, dynamic> json) {
    return UpstreamState(
      sourceListId: UuidValue.parse(json['sourceListId'] as String),
      version: json['version'] as int?,
      deleted: json['deleted'] == true,
    );
  }

  @override
  Future<SongList> fetchOne(String baseUrl, UuidValue id) async {
    final url = BackendUrl.join(
      baseUrl,
      '${BackendEndpoints.songLists}/${id.value}',
    );

    try {
      final response = await _send(
        () => _dio.get<Map<String, dynamic>>(url),
        url,
      );

      final data = response.data;
      if (data == null) {
        throw DioException(
          requestOptions: RequestOptions(path: url),
          type: DioExceptionType.badResponse,
          error: 'Liste vide dans la réponse',
        );
      }

      return RemoteSongListDto.fromJson(data).toDomain();
    } on DioException catch (e) {
      // Supprimée, ou abonnement révoqué : dans les deux cas il n'y a plus rien
      // à tirer, et l'appelant coupe le lien amont plutôt que d'insister.
      if (e.response?.statusCode == 404) throw const SongListGoneException();
      rethrow;
    }
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

  @override
  Future<ShareLink> share(String baseUrl, UuidValue id) async {
    final url = BackendUrl.join(
      baseUrl,
      '${BackendEndpoints.songLists}/${id.value}/share',
    );

    final response = await _send(
      () => _dio.post<Map<String, dynamic>>(url),
      url,
    );

    final data = response.data;
    final token = data?['token'];
    final code = data?['code'];
    final link = data?['link'];

    if (token is! String || code is! String || link is! String) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.badResponse,
        error: 'Réponse de partage inexploitable',
      );
    }

    return ShareLink(token: token, code: code, link: link);
  }

  @override
  Future<SubscriptionResult> subscribe(
    String baseUrl, {
    String? token,
    String? code,
  }) async {
    if ((token == null) == (code == null)) {
      throw ArgumentError('Fournissez soit un token, soit un code.');
    }

    final url = BackendUrl.join(baseUrl, BackendEndpoints.songListSubscribe);

    try {
      final response = await _send(
        () => _dio.post<Map<String, dynamic>>(
          url,
          data: token != null ? {'token': token} : {'code': code},
        ),
        url,
      );

      final data = response.data;
      final list = data?['list'];
      if (list is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: RequestOptions(path: url),
          type: DioExceptionType.badResponse,
          error: 'Réponse d\'abonnement sans liste',
        );
      }

      final existingCopyId = data?['existingCopyId'];

      return SubscriptionResult(
        source: RemoteSongListDto.fromJson(list).toDomain(),
        alreadyOwner: data?['alreadyOwner'] == true,
        existingCopyId: existingCopyId is String
            ? UuidValue.parse(existingCopyId)
            : null,
      );
    } on DioException catch (e) {
      // Jamais émis, mal recopié, ou pointant une liste supprimée depuis : le
      // serveur ne les distingue pas, et l'utilisateur n'a qu'une chose à
      // faire dans les trois cas — redemander un lien.
      if (e.response?.statusCode == 404) throw const ShareLinkNotFoundException();
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
