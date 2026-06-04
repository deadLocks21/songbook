import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/device_identity.service.dart';
import 'package:songbook/infrastructure/device/in_memory.device_identity.service.dart';
import 'package:songbook/infrastructure/device/shared_preferences.device_identity.service.dart';

part 'device_identity.service_provider.g.dart';

/// Provider for the device identity service. Uses `SharedPreferences` off the
/// web, in-memory on web.
@Riverpod(keepAlive: true)
DeviceIdentityService deviceIdentityService(Ref ref) {
  if (kIsWeb) {
    return InMemoryDeviceIdentityService();
  }
  return const SharedPreferencesDeviceIdentityService();
}
