import 'actions/home/actions.dart';
import 'actions/settings/actions.dart';
import 'actions/song_list_detail/actions.dart';
import 'actions/song_list_edit/actions.dart';
import 'actions/song_list_viewer/actions.dart';
import 'actions/song_lists/actions.dart';
import 'actions/song_viewer/actions.dart';

/// Interface de navigation fluente pour accéder aux actions de chaque page.
abstract class IFluentNavigation {
  HomePageActions get homePage;
  SettingsPageActions get settingsPage;
  SongViewerPageActions get songViewerPage;
  SongListsPageActions get songListsPage;
  SongListDetailPageActions get songListDetailPage;
  SongListEditPageActions get songListEditPage;
  SongListViewerPageActions get songListViewerPage;
}

/// Interface de base pour toutes les commandes de test.
abstract class FluentCommand {
  Future<void> execute();
}
