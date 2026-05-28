import 'package:flutter/foundation.dart';
import 'package:songbook/core/domain/model/log_level.dart';
import 'package:songbook/core/domain/services/logger.service.dart';

/// [LoggerService] that prints to the console via [debugPrint].
///
/// Used:
/// - In every non-release build as the primary sink.
/// - As one branch of [CompositeLoggerService] so the developer sees in
///   their console exactly what is shipped to Signoz (for calibration).
///
/// [debugPrint] is used on purpose rather than `dart:developer`'s `log()`:
/// it is the channel that actually surfaces in the `flutter run` terminal
/// and in `adb logcat`. `developer.log()` shows up only in DevTools'
/// Logging view, never in the terminal — which defeats the point of a
/// "console" logger during local debugging. The throttling [debugPrint]
/// applies also keeps logcat from dropping lines under load.
///
/// The output is a single line per record: `LEVEL message k=v k=v …`
/// followed by a stack trace when present. Cheap and grep-friendly.
///
/// Has no buffer — `flush()` is a no-op.
class ConsoleLoggerService implements LoggerService {
  /// Optional tag prefixed to the message. Useful to distinguish records
  /// that *also* went to Signoz when this service is wrapped in a
  /// [CompositeLoggerService] (e.g. `[→signoz]`).
  final String? prefix;

  const ConsoleLoggerService({this.prefix});

  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {
    final buf = StringBuffer();
    if (prefix != null) buf.write('$prefix ');
    // The level is part of the text since debugPrint has no severity param.
    buf.write('${level.otelSeverityText} ');
    buf.write(message);
    if (attributes.isNotEmpty) {
      buf.write(' ');
      buf.writeAll(
        attributes.entries.map((e) => '${e.key}=${_format(e.value)}'),
        ' ',
      );
    }
    if (error != null) buf.write(' error=${_format(error)}');
    debugPrint(buf.toString());
    if (stack != null) debugPrint(stack.toString());
  }

  @override
  Future<void> flush() async {}

  String _format(Object? v) {
    if (v == null) return 'null';
    if (v is String) {
      // Quote only if the value contains whitespace, otherwise the line
      // stays maximally grep-friendly.
      return v.contains(RegExp(r'\s')) ? '"$v"' : v;
    }
    return v.toString();
  }
}
