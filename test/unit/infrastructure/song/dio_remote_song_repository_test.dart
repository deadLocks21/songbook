import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/infrastructure/song/dio.remote_song.repository.dart';

void main() {
  group('DioRemoteSongRepository', () {
    test(
      'throws a DioException when the server accepts the connection but '
      'never responds (does not hang forever)',
      () async {
        // Serveur « trou noir » : il accepte la connexion TCP puis reste muet,
        // reproduisant le cas qui faisait pendre la sync à l'infini (les
        // timeouts internes de Dio ne couvrent pas ce cas).
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        final accepted = <Socket>[];
        server.listen(accepted.add);
        addTearDown(() async {
          for (final socket in accepted) {
            socket.destroy();
          }
          await server.close();
        });

        final repository = DioRemoteSongRepository(
          Dio(),
          requestTimeout: const Duration(milliseconds: 300),
        );

        await expectLater(
          repository.fetchSongs('http://127.0.0.1:${server.port}'),
          throwsA(isA<DioException>()),
        );
      },
    );
  });
}
