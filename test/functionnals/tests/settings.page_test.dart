import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';

import '../utils/index.dart';

void main() {
  group('SettingsPage', () {
    group('Apparence', () {
      testWidgets('should display theme selector with system mode by default', (
        tester,
      ) async {
        await (await startInSettingsPage(
          tester,
        )).expectThemeSelected(AppThemeMode.system).execute();
      });

      testWidgets('should switch to dark theme', (tester) async {
        await (await startInSettingsPage(
          tester,
        )).tapThemeDark().expectThemeSelected(AppThemeMode.dark).execute();
      });

      testWidgets('should switch to light theme', (tester) async {
        await (await startInSettingsPage(
          tester,
        )).tapThemeLight().expectThemeSelected(AppThemeMode.light).execute();
      });

      testWidgets('should switch back to auto theme', (tester) async {
        await (await startInSettingsPage(tester))
            .tapThemeDark()
            .expectThemeSelected(AppThemeMode.dark)
            .tapThemeAuto()
            .expectThemeSelected(AppThemeMode.system)
            .execute();
      });
    });

    group('URL du backend', () {
      testWidgets('should display backend URL in read-only mode by default', (
        tester,
      ) async {
        await (await startInSettingsPage(tester))
            .expectBackendUrlReadonly()
            .expectBackendUrlEditButtonVisible()
            .execute();
      });

      testWidgets('should enable editing when tapping edit button', (
        tester,
      ) async {
        await (await startInSettingsPage(tester))
            .tapBackendUrlEdit()
            .expectBackendUrlEditable()
            .expectBackendUrlEditButtonAbsent()
            .execute();
      });

      testWidgets('should cancel editing and restore original URL', (
        tester,
      ) async {
        await (await startInSettingsPage(tester))
            .tapBackendUrlEdit()
            .enterBackendUrl('https://new-url.com')
            .tapBackendUrlCancel()
            .expectBackendUrlReadonly()
            .expectBackendUrl('https://songbook.dtfh.fr')
            .execute();
      });

      testWidgets('should enable save button only when URL is modified', (
        tester,
      ) async {
        await (await startInSettingsPage(tester))
            .tapBackendUrlEdit()
            .expectSaveButtonDisabled()
            .enterBackendUrl('https://new-url.com')
            .expectSaveButtonEnabled()
            .execute();
      });
    });

    group('Base de données', () {
      testWidgets(
        'should show confirmation dialog when tapping clear database',
        (tester) async {
          await (await startInSettingsPage(
            tester,
          )).tapClearDatabase().expectClearDatabaseDialogVisible().execute();
        },
      );

      testWidgets('should dismiss dialog when cancelling clear database', (
        tester,
      ) async {
        await (await startInSettingsPage(tester))
            .tapClearDatabase()
            .expectClearDatabaseDialogVisible()
            .tapCancelClearDatabase()
            .expectClearDatabaseDialogDismissed()
            .execute();
      });
    });
  });
}
