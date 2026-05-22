/// Mutable bag of cross-cutting identity attributes attached to every
/// log record via the `LoggerApplicationService` dynamic resolver.
///
/// Held by a single keepAlive provider so it stays stable across the app
/// lifetime:
///
/// - [sessionId] is fixed at construction (one per app launch) — every
///   log line from the same run shares it, so a session is reconstructable
///   in Signoz by filtering on `session.id`.
/// - [deviceId] starts null and is filled in once at startup after the
///   async keychain read resolves. Until then, logs simply omit it.
class LogContext {
  final String sessionId;
  String? deviceId;

  LogContext({required this.sessionId, this.deviceId});

  Map<String, Object?> toAttributes() => {
    'session.id': sessionId,
    if (deviceId != null) 'device.id': deviceId,
  };
}
