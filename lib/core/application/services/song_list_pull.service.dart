import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_diff.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Ce qu'un tirage a donné.
sealed class PullResult {
  const PullResult();
}

/// La source n'a rien de nouveau, ou ce qu'elle a ne change rien chez moi.
class NothingToPull extends PullResult {
  const NothingToPull();
}

/// Ma copie était intacte : le tirage s'est appliqué sans rien demander.
class PulledAutomatically extends PullResult {
  final int changeCount;

  const PulledAutomatically(this.changeCount);
}

/// J'avais modifié ma copie : il faut arbitrer.
class NeedsReview extends PullResult {
  final PullPreview preview;

  const NeedsReview(this.preview);
}

/// La source a disparu, ou n'est plus lisible. Le lien amont est coupé, la
/// copie reste.
class UpstreamGone extends PullResult {
  const UpstreamGone();
}

/// Le tirage n'a pas pu avoir lieu : réseau, serveur, session expirée.
///
/// Le service ne la produit pas lui-même — il laisse remonter l'exception —
/// mais elle appartient à cette énumération pour que l'UI n'ait qu'un seul type
/// à traiter, et qu'aucune issue ne puisse être oubliée.
class PullFailed extends PullResult {
  const PullFailed();
}

/// De quoi afficher l'écran de revue, et appliquer ensuite.
class PullPreview {
  final SongList copy;
  final SongList source;
  final UpstreamDiff diff;

  const PullPreview({
    required this.copy,
    required this.source,
    required this.diff,
  });
}

/// Tirer les évolutions d'une source dans la copie qu'on en a faite.
///
/// Rien ne remonte jamais : cette classe lit la source et écrit la copie, dans
/// ce sens uniquement.
class SongListPullService {
  final SongListRepository _local;
  final RemoteSongListRepository _remote;

  const SongListPullService(this._local, this._remote);

  /// Va chercher ce qui a changé en amont de [copyId].
  ///
  /// Applique tout seul quand la copie n'a pas été touchée depuis le dernier
  /// tirage — le cas courant, qui ne mérite pas d'écran.
  Future<PullResult> pull(String baseUrl, UuidValue copyId) async {
    final copy = await _local.getSongListById(copyId);
    final upstream = copy?.upstream;
    if (copy == null || upstream == null) return const NothingToPull();

    final SongList source;
    try {
      source = await _remote.fetchOne(baseUrl, upstream.sourceListId);
    } on SongListGoneException {
      return const UpstreamGone();
    }

    final base = await _local.getUpstreamSnapshot(copyId);
    final diff = UpstreamDiff.between(base: base, mine: copy, source: source);

    if (diff.isEmpty) {
      // Rien à reprendre, mais la source a pu avancer : on note où elle en est
      // pour ne pas reposer la question au prochain passage.
      await _advance(copy, source);
      return const NothingToPull();
    }

    // Copie intacte : appliquer en silence. Poser la question ici reviendrait à
    // demander d'arbitrer un conflit qui n'existe pas.
    if (base != null && base.describes(copy)) {
      await _apply(copy, source, diff, diff.changes.map((c) => c.id).toSet());
      return PulledAutomatically(diff.changes.length);
    }

    return NeedsReview(PullPreview(copy: copy, source: source, diff: diff));
  }

  /// Applique les changements retenus après revue.
  Future<void> applyReviewed(PullPreview preview, Set<String> selected) =>
      _apply(preview.copy, preview.source, preview.diff, selected);

  /// Coupe le lien amont sans toucher à la copie : elle redevient une liste
  /// ordinaire, à son propriétaire.
  Future<void> unfollow(UuidValue copyId) async {
    final copy = await _local.getSongListById(copyId);
    if (copy == null) return;

    await _local.updateSongList(
      SongList(
        id: copy.id,
        scheduledAt: copy.scheduledAt,
        createdAt: copy.createdAt,
        entries: copy.entries,
        title: copy.title,
        version: copy.version,
      ),
    );
  }

  Future<void> _apply(
    SongList copy,
    SongList source,
    UpstreamDiff diff,
    Set<String> selected,
  ) async {
    await _local.updateSongList(diff.applyTo(copy, selected: selected));
    await _advance(copy, source);
  }

  /// Fait avancer le repère et la base, **même quand tout n'a pas été retenu**.
  ///
  /// Un changement écarté ne revient donc pas solliciter au tirage suivant :
  /// refuser, c'est décider. Garder la base en arrière transformerait chaque
  /// tirage en rappel des mêmes refus.
  Future<void> _advance(SongList copy, SongList source) async {
    final upstream = copy.upstream;
    final sourceVersion = source.version;
    if (upstream == null || sourceVersion == null) return;

    await _local.saveUpstreamSnapshot(UpstreamSnapshot.of(copy.id, source));

    // Relu plutôt que réutilisé : `_apply` vient peut-être de le réécrire, et
    // repartir de l'instance d'avant écraserait ce qui vient d'être appliqué.
    final current = await _local.getSongListById(copy.id);
    if (current == null) return;

    await _local.updateSongList(
      current.copyWith(upstream: upstream.pulledAt(sourceVersion)),
    );
  }
}
