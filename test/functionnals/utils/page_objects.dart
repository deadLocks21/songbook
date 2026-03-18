import 'package:flutter_test/flutter_test.dart';

import 'actions/home/actions.dart';
import 'actions/song_list_detail/actions.dart';
import 'actions/song_list_edit/actions.dart';
import 'actions/song_list_viewer/actions.dart';
import 'actions/song_lists/actions.dart';
import 'actions/song_viewer/actions.dart';
import 'types.dart';

/// Façade principale pour accéder aux actions de toutes les pages.
class PageObjects implements IFluentNavigation {
  final WidgetTester tester;

  PageObjects(this.tester);

  @override
  HomePageActions get homePage => HomePageActions(this, tester);

  @override
  SongViewerPageActions get songViewerPage =>
      SongViewerPageActions(this, tester);

  @override
  SongListsPageActions get songListsPage => SongListsPageActions(this, tester);

  @override
  SongListDetailPageActions get songListDetailPage =>
      SongListDetailPageActions(this, tester);

  @override
  SongListEditPageActions get songListEditPage =>
      SongListEditPageActions(this, tester);

  @override
  SongListViewerPageActions get songListViewerPage =>
      SongListViewerPageActions(this, tester);
}
