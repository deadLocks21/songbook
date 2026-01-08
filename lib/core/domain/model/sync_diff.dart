import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/song.dart';

/// Modèle représentant les différences calculées entre les données distantes et locales.
class SyncDiff {
  /// Songs à ajouter (nouveaux sur le serveur, absents localement).
  final List<SongToAdd> toAdd;

  /// Songs à mettre à jour (updatedAt plus récent sur le serveur).
  final List<SongToUpdate> toUpdate;

  /// Songs à supprimer (présents localement mais disparus du serveur).
  final List<SongToDelete> toDelete;

  SyncDiff({
    required this.toAdd,
    required this.toUpdate,
    required this.toDelete,
  });

  /// Retourne true si aucune modification n'est nécessaire.
  bool get isEmpty => toAdd.isEmpty && toUpdate.isEmpty && toDelete.isEmpty;

  /// Retourne le nombre total d'actions à effectuer.
  int get totalActions => toAdd.length + toUpdate.length + toDelete.length;
}

/// Représente un song à ajouter (nouveau sur le serveur).
class SongToAdd {
  final RemoteSong remoteSong;

  SongToAdd({required this.remoteSong});
}

/// Représente un song à mettre à jour (version plus récente sur le serveur).
class SongToUpdate {
  final Song localSong;
  final RemoteSong remoteSong;

  SongToUpdate({required this.localSong, required this.remoteSong});
}

/// Représente un song à supprimer (disparu du serveur).
class SongToDelete {
  final Song localSong;

  SongToDelete({required this.localSong});
}
