import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/device_identity.service.dart';

/// Persists the device id in the OS keychain/keystore via
/// `flutter_secure_storage`, mirroring the storage options already used
/// for the API password in `SharedPreferencesSettingsRepository`.
///
/// The value survives app restarts but is cleared on uninstall — which
/// is the desired semantics for a per-install identifier.
class SecureStorageDeviceIdentityService implements DeviceIdentityService {
  static const String _key = 'device_id';

  final FlutterSecureStorage _storage;

  const SecureStorageDeviceIdentityService([
    this._storage = const FlutterSecureStorage(
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock,
        synchronizable: false,
      ),
    ),
  ]);

  @override
  Future<String> getDeviceId() async {
    try {
      final existing = await _storage.read(key: _key);
      if (existing != null && existing.isNotEmpty) return existing;
      final id = UuidValue.generate().value;
      await _storage.write(key: _key, value: id);
      return id;
    } catch (_) {
      // Storage unavailable: hand back an ephemeral id so logging keeps
      // working. Not persisted — next launch tries the keychain again.
      return UuidValue.generate().value;
    }
  }
}
