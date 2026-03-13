import 'package:flutter/material.dart';
import 'package:songbook/ui/pages/home/widgets/songs_tab.widget.dart';
import 'package:songbook/ui/pages/settings/settings.page.dart';
import 'package:songbook/ui/pages/song_lists/song_lists.page.dart';

/// Page d'accueil avec BottomNavigationBar pour naviguer
/// entre les chants et les listes de chants.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _tabs = <Widget>[SongsTab(), SongListsPage(), SettingsPage()];

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
            onTap: (index) => setState(() => _currentIndex = index),
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
