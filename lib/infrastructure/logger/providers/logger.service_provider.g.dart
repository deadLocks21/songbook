// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(loggerService)
final loggerServiceProvider = LoggerServiceProvider._();

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

final class LoggerServiceProvider
    extends $FunctionalProvider<LoggerService, LoggerService, LoggerService>
    with $Provider<LoggerService> {
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
  LoggerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerServiceHash();

  @$internal
  @override
  $ProviderElement<LoggerService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggerService create(Ref ref) {
    return loggerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerService>(value),
    );
  }
}

String _$loggerServiceHash() => r'd4776e190e5d6bf22bee8a513efc6e7be48c7fbd';

/// App-wide mutable log context. One [LogContext.sessionId] per launch;
/// [LogContext.deviceId] is filled in at startup once the keychain read
/// resolves (see `main`). `keepAlive` so the session id stays stable.

@ProviderFor(logContext)
final logContextProvider = LogContextProvider._();

/// App-wide mutable log context. One [LogContext.sessionId] per launch;
/// [LogContext.deviceId] is filled in at startup once the keychain read
/// resolves (see `main`). `keepAlive` so the session id stays stable.

final class LogContextProvider
    extends $FunctionalProvider<LogContext, LogContext, LogContext>
    with $Provider<LogContext> {
  /// App-wide mutable log context. One [LogContext.sessionId] per launch;
  /// [LogContext.deviceId] is filled in at startup once the keychain read
  /// resolves (see `main`). `keepAlive` so the session id stays stable.
  LogContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logContextProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logContextHash();

  @$internal
  @override
  $ProviderElement<LogContext> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogContext create(Ref ref) {
    return logContext(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogContext value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogContext>(value),
    );
  }
}

String _$logContextHash() => r'dc29eedd36260fbb4e04374472d69f413c3be4bc';

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

@ProviderFor(logger)
final loggerProvider = LoggerProvider._();

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

final class LoggerProvider
    extends
        $FunctionalProvider<
          LoggerApplicationService,
          LoggerApplicationService,
          LoggerApplicationService
        >
    with $Provider<LoggerApplicationService> {
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
  LoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerHash();

  @$internal
  @override
  $ProviderElement<LoggerApplicationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoggerApplicationService create(Ref ref) {
    return logger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggerApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggerApplicationService>(value),
    );
  }
}

String _$loggerHash() => r'67ee01fc07a27c9ee89ef2e3a8fbbc49c5ff4a12';
