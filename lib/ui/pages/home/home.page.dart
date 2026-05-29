import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/infrastructure/recueil/providers/recueil.providers.dart';
import 'package:songbook/ui/pages/home/widgets/songs_tab.widget.dart';
import 'package:songbook/ui/pages/settings/settings.page.dart';
import 'package:songbook/ui/pages/song_lists/song_lists.page.dart';

/// Page d'accueil avec BottomNavigationBar pour naviguer
/// entre les chants et les listes de chants.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  /// Index de l'onglet « Paramètres » dans [_tabs].
  static const _settingsTabIndex = 2;

  static const _tabs = <Widget>[SongsTab(), SongListsPage(), SettingsPage()];

  void _onTabTapped(int index) {
    // À l'ouverture des réglages, on rafraîchit le décompte « X/N téléchargé(s) »
    // en relançant uniquement les vérifications disque (le catalogue réseau
    // reste mémoïsé).
    if (index == _settingsTabIndex) {
      ref.invalidate(recueilSongStatsProvider);
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Songbook')),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Chants',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.queue_music),
                label: 'Listes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Paramètres',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
