import 'package:flutter_test/flutter_test.dart';

import 'actions/home/actions.dart';
import 'actions/song_viewer/actions.dart';

/// Interface de navigation fluente pour accéder aux actions de chaque page.
abstract class IFluentNavigation {
  HomePageActions get homePage;
  SongViewerPageActions get songViewerPage;
}

/// Interface de base pour toutes les commandes de test.
abstract class FluentCommand {
  Future<void> execute();
}
