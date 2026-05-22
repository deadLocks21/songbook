import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/device_identity.service.dart';

/// In-memory device id used on web (no secure storage) and in tests.
/// Stable for the lifetime of the process, regenerated on each launch.
class InMemoryDeviceIdentityService implements DeviceIdentityService {
  String? _id;

  @override
  Future<String> getDeviceId() async => _id ??= UuidValue.generate().value;
}
