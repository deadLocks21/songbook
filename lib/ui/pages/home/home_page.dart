import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/ui/pages/home/providers/search_provider.dart';
import 'package:songbook/ui/pages/home/song_card.dart';
import 'package:songbook/ui/pages/settings/settings_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSongsAsync = ref.watch(filteredSongsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Songbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchField(ref),
          ),
          Expanded(
            child: filteredSongsAsync.when(
              data: (songs) => _buildSongGrid(songs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erreur lors du chargement des chants: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher par code ou titre...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => ref.read(searchQueryProvider.notifier).clear(),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
      onChanged: (value) =>
          ref.read(searchQueryProvider.notifier).update(value),
    );
  }

  Widget _buildSongGrid(List<dynamic> songs) {
    if (songs.isEmpty) {
      return const Center(
        child: Text(
          'Aucun chant trouvé',
          style: TextStyle(fontSize: 18.0, color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 360).floor().clamp(1, 5);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            key: const Key('songGridView'),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 114.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: songs.length,
            itemBuilder: (context, index) => SongCard(song: songs[index]),
          ),
        );
      },
    );
  }
}
