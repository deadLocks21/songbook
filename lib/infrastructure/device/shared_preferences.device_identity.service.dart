import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/device_identity.service.dart';

/// Persists the device id in `SharedPreferences`, alongside the rest of the
/// app's settings.
///
/// The value survives app restarts but is cleared on uninstall — which is the
/// desired semantics for a per-install identifier.
class SharedPreferencesDeviceIdentityService implements DeviceIdentityService {
  static const String _key = 'device_id';

  const SharedPreferencesDeviceIdentityService();

  @override
  Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_key);
      if (existing != null && existing.isNotEmpty) return existing;
      final id = UuidValue.generate().value;
      await prefs.setString(_key, id);
      return id;
    } catch (_) {
      // Storage unavailable: hand back an ephemeral id so logging keeps
      // working. Not persisted — next launch tries the store again.
      return UuidValue.generate().value;
    }
  }
}
