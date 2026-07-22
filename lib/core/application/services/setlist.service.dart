import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

class SetlistService {
  final SongListRepository _songListRepository;
  final SongRepository _songRepository;

  /// Appelé après chaque écriture locale aboutie, pour que la modification
  /// parte vers le serveur sans attendre la prochaine synchro.
  ///
  /// Branché ici plutôt qu'à chaque endroit de l'UI qui enregistre : toute
  /// écriture passe par ce service, donc aucune ne peut être oubliée. Le rappel
  /// ne doit ni bloquer ni échouer — l'écriture locale, elle, est déjà faite.
  final void Function()? _onLocalChange;

  const SetlistService(
    this._songListRepository,
    this._songRepository, {
    void Function()? onLocalChange,
  }) : _onLocalChange = onLocalChange;

  Future<List<SongListDto>> getAllSetlists() async {
    final songLists = await _songListRepository.getAllSongLists();
    final songs = await _songRepository.getAllSongs();

    final songInfo = {
      for (final s in songs) s.id: (code: s.code, name: s.name),
    };

    final dtos = songLists
        .map((sl) => SongListDto.fromDomain(sl, songInfo))
        .toList();

    dtos.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return dtos;
  }

  Future<SongListDto?> getDetail(String songListId) async {
    final songList = await _songListRepository.getSongListById(
      UuidValue.parse(songListId),
    );
    if (songList == null) return null;

    final songIds = songList.entries.map((e) => e.songId).toList();
    final songs = await _songRepository.getSongsByIds(songIds);
    final songInfo = {
      for (final s in songs) s.id: (code: s.code, name: s.name),
    };

    return SongListDto.fromDomain(songList, songInfo);
  }

  Future<void> save(SongListDto dto) async {
    final songList = dto.toDomain();
    final existing = await _songListRepository.getSongListById(songList.id);

    if (existing != null) {
      // La version serveur connue n'appartient pas au DTO (l'UI n'en fait
      // rien) : on la reprend de la copie locale, sinon chaque enregistrement
      // repartirait comme une création.
      //
      // Le lien amont suit la même règle, et pour un motif plus sévère :
      // l'oublier ferait partir la prochaine écriture sans `sourceListId`,
      // c'est-à-dire désabonnerait la liste au premier enregistrement.
      await _songListRepository.updateSongList(
        songList.copyWith(
          version: existing.version,
          title: existing.title,
          upstream: existing.upstream,
        ),
      );
    } else {
      await _songListRepository.addSongList(songList);
    }

    _onLocalChange?.call();
  }

  Future<void> delete(String songListId) async {
    await _songListRepository.deleteSongList(UuidValue.parse(songListId));
    _onLocalChange?.call();
  }
}
