import 'package:flutter_test/flutter_test.dart';

import 'actions/home/actions.dart';
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
}
