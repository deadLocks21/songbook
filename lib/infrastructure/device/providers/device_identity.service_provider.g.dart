// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_identity.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the device identity service. Uses `SharedPreferences` off the
/// web, in-memory on web.

@ProviderFor(deviceIdentityService)
final deviceIdentityServiceProvider = DeviceIdentityServiceProvider._();

/// Provider for the device identity service. Uses `SharedPreferences` off the
/// web, in-memory on web.

final class DeviceIdentityServiceProvider
    extends
        $FunctionalProvider<
          DeviceIdentityService,
          DeviceIdentityService,
          DeviceIdentityService
        >
    with $Provider<DeviceIdentityService> {
  /// Provider for the device identity service. Uses `SharedPreferences` off the
  /// web, in-memory on web.
  DeviceIdentityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceIdentityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceIdentityServiceHash();

  @$internal
  @override
  $ProviderElement<DeviceIdentityService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceIdentityService create(Ref ref) {
    return deviceIdentityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceIdentityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceIdentityService>(value),
    );
  }
}

String _$deviceIdentityServiceHash() =>
    r'579972cf37dd94ebf7e207dc534833f58fec466a';
