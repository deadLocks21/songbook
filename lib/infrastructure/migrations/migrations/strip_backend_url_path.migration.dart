import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/utils/backend_url.dart';
import 'package:songbook/infrastructure/migrations/migration.dart';
import 'package:songbook/infrastructure/settings/shared_preferences.settings_repository.dart';

/// Strips any path/query/fragment from a previously-saved backend URL so the
/// stored value is a bare origin (e.g. `https://songbook.dtfh.fr`).
///
/// API paths are now appended in code (see `BackendEndpoints`), so a stored
/// URL still carrying the old `/api/songs/examples` suffix would otherwise be
/// doubled at request time. Fresh installs never stored an explicit value —
/// they fall back to the (already domain-only) default — so this only rewrites
/// URLs a user actually saved.
///
/// Operates on SharedPreferences directly rather than the DB: that is where
/// the backend URL lives. Web has no SharedPreferences-backed DB migration
/// (its repository is in-memory and resets each launch), and the runner only
/// runs off-web, so this never executes there.
class StripBackendUrlPathMigration extends Migration {
  @override
  String get id => '2026_05_27_strip_backend_url_path';

  @override
  Future<bool> shouldRun(MigrationContext ctx) async {
    final stored = await _storedUrl();
    return stored != null && BackendUrl.normalize(stored) != stored;
  }

  @override
  Future<void> execute(MigrationContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(
      SharedPreferencesSettingsRepository.backendUrlKey,
    );
    if (stored == null) return;

    final normalized = BackendUrl.normalize(stored);
    if (normalized == stored) return;

    await prefs.setString(
      SharedPreferencesSettingsRepository.backendUrlKey,
      normalized,
    );
    ctx.logger.info(
      'migration.backend_url.path_stripped',
      attrs: {'backend.url.before': stored, 'backend.url.after': normalized},
    );
  }

  Future<String?> _storedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPreferencesSettingsRepository.backendUrlKey);
  }
}
