import 'dart:io';

import 'package:dio/dio.dart';

/// Faux Dio qui écrit du contenu factice au lieu de faire des appels HTTP.
/// Utilisé pour tester DioResourceCacheRepository sans réseau.
class FakeDio with DioMixin implements Dio {
  FakeDio() {
    options = BaseOptions();
    httpClientAdapter = _NoOpAdapter();
  }

  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    final file = File(savePath as String);
    await file.parent.create(recursive: true);
    await file.writeAsString('fake content from $urlPath');
    return Response(
      requestOptions: RequestOptions(path: urlPath),
      statusCode: 200,
    );
  }
}

class _NoOpAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw UnimplementedError('FakeDio does not support HTTP requests');
  }

  @override
  void close({bool force = false}) {}
}
