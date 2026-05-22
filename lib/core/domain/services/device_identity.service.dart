/// Provides a stable, per-install device identifier.
///
/// The id is generated once on first launch and persisted, so every log
/// record emitted from the same install carries the same `device.id`.
/// This is the anchor used to answer "which device hit this problem?"
/// when triaging logs in Signoz — songbook has no user accounts, so the
/// device is the finest-grained "who" available.
abstract interface class DeviceIdentityService {
  /// Returns the persisted device id, generating and storing one on the
  /// first call. MUST NOT throw — a failure to read storage falls back to
  /// a fresh (non-persisted) id rather than crashing the caller.
  Future<String> getDeviceId();
}
