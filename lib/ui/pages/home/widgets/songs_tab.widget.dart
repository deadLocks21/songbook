import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/home/providers/search_provider.dart';
import 'package:songbook/ui/pages/home/widgets/song_card.widget.dart';

/// Onglet affichant la grille de chants avec recherche.
class SongsTab extends ConsumerStatefulWidget {
  const SongsTab({super.key});

  @override
  ConsumerState<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends ConsumerState<SongsTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSongsAsync = ref.watch(filteredSongsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSearchField(),
        ),
        Expanded(
          child: filteredSongsAsync.when(
            data: (songs) => _buildSongGrid(songs),
            loading: () => const Center(
              key: Key('loadingIndicator'),
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) {
              debugPrint('Error loading songs: $error\n$stack');
              final userMessage = ErrorMessageService.getNetworkErrorMessage(
                error,
              );
              return Center(
                key: const Key('errorMessage'),
                child: Text(
                  'Erreur lors du chargement des chants: $userMessage',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final searchQuery = ref.watch(searchQueryProvider);

    return TextField(
      key: const Key('searchField'),
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher par code ou titre...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).clear();
                },
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

  Widget _buildSongGrid(List<SongDto> songs) {
    // L'historique arrive avec les listes, donc un instant après le catalogue :
    // les cartes s'affichent sans en attendant, plutôt que de retarder la
    // grille entière.
    final schedules =
        ref.watch(songSchedulesProvider()).value ??
        const <String, SongSchedule>{};

    if (songs.isEmpty) {
      return const Center(
        key: Key('emptyMessage'),
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
              // La carte a gagné la ligne d'historique, mais le code a rejoint
              // le titre : au total, la hauteur d'avant.
              mainAxisExtent: 114.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongCard(
                song: song,
                schedule: schedules[song.id] ?? SongSchedule.never,
              );
            },
          ),
        );
      },
    );
  }
}
