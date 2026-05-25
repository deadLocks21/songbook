import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/logger.service.dart';
import 'package:songbook/infrastructure/logger/composite.logger.service.dart';
import 'package:songbook/infrastructure/logger/console.logger.service.dart';
import 'package:songbook/infrastructure/logger/log_context.dart';
import 'package:songbook/infrastructure/logger/signoz.logger.service.dart';

part 'logger.service_provider.g.dart';

/// Build-time Signoz OTLP HTTP endpoint, e.g.
/// `https://ingest.eu.signoz.cloud:443/v1/logs`. Empty → Signoz disabled.
///
/// Pass via:
/// `flutter run --dart-define=SIGNOZ_INGEST_URL=https://…/v1/logs`
const String _kSignozEndpoint = String.fromEnvironment('SIGNOZ_INGEST_URL');

/// Build-time Signoz Cloud ingestion key. Sent as `signoz-access-token`.
/// Leave empty for self-hosted deployments without auth.
const String _kSignozKey = String.fromEnvironment('SIGNOZ_INGESTION_KEY');

/// Optional override for the `deployment.environment` resource attribute.
/// Defaults to `production` in release builds, `development` otherwise.
const String _kEnvOverride = String.fromEnvironment('SIGNOZ_ENV');

/// App version surfaced as the `service.version` resource attribute.
/// The CI build can inject the real value via
/// `--dart-define=APP_VERSION=$VERSION+$BUILD_NUMBER`. Defaults to a
/// sentinel so unconfigured local builds are obvious in Signoz.
const String _kAppVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: 'dev',
);

/// Single app-wide [LoggerService].
///
/// Selection logic:
///
/// | Mode    | SIGNOZ_INGEST_URL set | Implementation                          |
/// |---------|-----------------------|-----------------------------------------|
/// | release | no                    | [ConsoleLoggerService] (fail-safe)      |
/// | release | yes                   | [SignozLoggerService] alone             |
/// | debug   | no                    | [ConsoleLoggerService] alone            |
/// | debug   | yes                   | [CompositeLoggerService]: console+signoz|
///
/// The debug+signoz branch is what lets the developer see in their own
/// console exactly what is being shipped — see `calibration` discussion
/// in `LoggerService`'s doc.
///
/// `keepAlive` because the underlying Signoz adapter holds a periodic
/// timer + dio client that would be wasteful to spin up on demand.
@Riverpod(keepAlive: true)
LoggerService loggerService(Ref ref) {
  final hasSignoz = _kSignozEndpoint.isNotEmpty;

  final console = ConsoleLoggerService(
    prefix: hasSignoz && !kReleaseMode ? '[→signoz]' : null,
  );

  if (!hasSignoz) {
    return console;
  }

  final signoz = SignozLoggerService(
    endpoint: _kSignozEndpoint,
    ingestionKey: _kSignozKey.isEmpty ? null : _kSignozKey,
    resourceAttributes: _resourceAttributes(),
  );
  ref.onDispose(signoz.dispose);

  if (kReleaseMode) {
    return signoz;
  }
  // Debug build with Signoz wired in: mirror to console for calibration.
  return CompositeLoggerService([console, signoz]);
}

/// App-wide mutable log context. One [LogContext.sessionId] per launch;
/// [LogContext.deviceId] is filled in at startup once the keychain read
/// resolves (see `main`). `keepAlive` so the session id stays stable.
@Riverpod(keepAlive: true)
LogContext logContext(Ref ref) {
  return LogContext(sessionId: UuidValue.generate().value);
}

/// Ergonomic facade consumed by usecases / UI / `main.dart`.
///
/// The dynamic context resolver reads [logContextProvider] via `ref.read`
/// — **not** `ref.watch` — at every emission, so the logger instance is
/// stable while each record still carries the current `session.id` /
/// `device.id`. Rebuilding it would tear down the Signoz batch buffer.
///
/// Attributes shipped when applicable:
///
/// | Key          | Source                | When present                |
/// |--------------|-----------------------|-----------------------------|
/// | `session.id` | per-launch UUID       | always                      |
/// | `device.id`  | persisted install id  | once resolved at startup    |
///
/// `service.version`, `os.type`, `deployment.environment` are attached
/// once per batch as OTLP *resource* attributes (see [loggerService]).
///
/// `keepAlive` so the underlying Signoz batch buffer stays alive across
/// the app lifetime rather than being torn down on provider disposal.
@Riverpod(keepAlive: true)
LoggerApplicationService logger(Ref ref) {
  return LoggerApplicationService(
    ref.watch(loggerServiceProvider),
    resolveContext: () => ref.read(logContextProvider).toAttributes(),
  );
}

Map<String, Object?> _resourceAttributes() {
  String env;
  if (_kEnvOverride.isNotEmpty) {
    env = _kEnvOverride;
  } else {
    env = kReleaseMode ? 'production' : 'development';
  }
  return {
    'service.name': 'songbook',
    'service.version': _kAppVersion,
    'deployment.environment': env,
    'os.type': _osType(),
    'container.name': 'songbook-flutter',
    'host.name': 'fr.dtfh.songbook',
  };
}

String _osType() {
  // `Platform` is unavailable on web; keep the catch defensively in case
  // the web target gets enabled.
  try {
    return Platform.operatingSystem;
  } catch (_) {
    return 'unknown';
  }
}
