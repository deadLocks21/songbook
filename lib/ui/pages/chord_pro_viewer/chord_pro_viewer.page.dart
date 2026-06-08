import 'package:chord_pro/chord_pro.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/key_label.dart';

/// Affiche le contenu d'un ChordPro déjà parsé et transposé : en-tête
/// (métadonnées) puis sections (couplets, refrains, …).
///
/// Sans Scaffold ni AppBar : le widget est conçu pour être intégré dans une
/// page hôte (la visionneuse de chant). La transposition est portée par le
/// parent, qui fournit un [song] déjà transposé et, au besoin, le panneau via
/// [showChordProTransposeSheet].
class ChordProView extends StatelessWidget {
  const ChordProView({super.key, required this.song});

  /// Le chant ChordPro à afficher, déjà transposé si nécessaire.
  final Song song;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(metadata: song.metadata),
          const SizedBox(height: 20),
          ..._buildSections(song.sections),
        ],
      ),
    );
  }

  /// Construit les sections en leur attribuant un libellé (Couplet numéroté,
  /// Refrain, …) selon leur type.
  List<Widget> _buildSections(List<Section> sections) {
    final widgets = <Widget>[];
    final copyrightLines = <Line>[];
    var verseNumber = 0;

    void addSection(Section section, String? heading, {bool isChorus = false}) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 48));
      widgets.add(
        _SectionView(section: section, heading: heading, isChorus: isChorus),
      );
    }

    for (final section in sections) {
      if (section.lines.isEmpty) continue;

      // Les lignes « loose » qui ne sont que des commentaires (copyright,
      // attribution en tête de chant) ne sont pas un couplet : on les met de
      // côté pour les afficher en pied de page, et le reste devient le couplet.
      if (section.kind == SectionKind.loose) {
        var i = 0;
        while (i < section.lines.length &&
            section.lines[i].kind == LineKind.comment) {
          i++;
        }
        copyrightLines.addAll(section.lines.sublist(0, i));
        final body = section.lines.sublist(i);
        if (body.isEmpty) continue;
        verseNumber++;
        addSection(
          Section(kind: SectionKind.loose, lines: body, span: section.span),
          'Couplet $verseNumber',
        );
        continue;
      }

      String? heading;
      switch (section.kind) {
        case SectionKind.verse:
          verseNumber++;
          heading = 'Couplet $verseNumber';
        case SectionKind.chorus:
          heading = section.isChorusRecall ? 'Refrain (reprise)' : 'Refrain';
        case SectionKind.bridge:
          heading = 'Pont';
        case SectionKind.tab:
          heading = 'Tablature';
        case SectionKind.grid:
          heading = 'Grille';
        default:
          heading = section.customKind ?? section.label;
      }
      // Un libellé explicite dans le fichier prime sur le libellé déduit.
      if (section.label != null && section.label!.isNotEmpty) {
        heading = section.label;
      }

      addSection(
        section,
        heading,
        isChorus: section.kind == SectionKind.chorus,
      );
    }

    if (copyrightLines.isNotEmpty) {
      widgets.add(const SizedBox(height: 24));
      widgets.add(_Copyright(lines: copyrightLines));
    }
    return widgets;
  }
}

/// Ouvre le panneau de transposition en bas de l'écran, laissant le contenu
/// visible au-dessus (barrière non assombrie). [onTranspose] reçoit le delta de
/// demi-tons à appliquer ; le parent met à jour son état de transposition et
/// re-rend le contenu transposé. Si [originalKey] est fournie, la valeur
/// centrale affiche la tonalité obtenue plutôt que le nombre de demi-tons.
void showChordProTransposeSheet(
  BuildContext context, {
  required int semitones,
  required ValueChanged<int> onTranspose,
  ValueListenable<String?>? originalKey,
}) {
  var current = semitones;
  showModalBottomSheet<void>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) => _TransposeSheet(
        semitones: current,
        originalKey: originalKey,
        onTranspose: (delta) {
          current = (current + delta).clamp(-11, 11);
          onTranspose(delta);
          // Reconstruit le panneau pour refléter la nouvelle valeur.
          setSheetState(() {});
        },
      ),
    ),
  );
}

/// Mentions de copyright / attribution, affichées en pied de page.
class _Copyright extends StatelessWidget {
  const _Copyright({required this.lines});

  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
        const SizedBox(height: 4),
        for (final line in lines)
          Text(
            line.comment ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.metadata});

  final Metadata metadata;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      if (metadata.subtitles.isNotEmpty) metadata.subtitles.join(' · '),
      if (metadata.artists.isNotEmpty) metadata.artists.join(', '),
    ].where((s) => s.isNotEmpty).join(' — ');
    final infos = [
      if (metadata.key != null) 'Tonalité : ${metadata.key}',
      if (metadata.capo != null) 'Capo : ${metadata.capo}',
      if (metadata.tempo != null) 'Tempo : ${metadata.tempo}',
    ].join('   ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle.isNotEmpty)
          Text(subtitle, style: theme.textTheme.titleSmall),
        if (infos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              infos,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}

/// Panneau de transposition affiché en bas de l'écran. Compact, il laisse la
/// partition visible au-dessus.
class _TransposeSheet extends StatelessWidget {
  const _TransposeSheet({
    required this.semitones,
    required this.onTranspose,
    this.originalKey,
  });

  final int semitones;
  final ValueChanged<int> onTranspose;

  /// Tonalité d'origine observable : le panneau peut être ouvert avant la fin
  /// du parsing, il se rafraîchit alors dès qu'elle est résolue.
  final ValueListenable<String?>? originalKey;

  @override
  Widget build(BuildContext context) {
    final listenable = originalKey;
    final controls = listenable == null
        ? ChordProTransposeControls(
            semitones: semitones,
            onTranspose: onTranspose,
          )
        : ValueListenableBuilder<String?>(
            valueListenable: listenable,
            builder: (context, key, _) => ChordProTransposeControls(
              semitones: semitones,
              originalKey: key,
              onTranspose: onTranspose,
            ),
          );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: controls,
      ),
    );
  }
}

/// Contrôles de transposition réutilisables : libellé « Transposition » et
/// boutons −1 / +1 encadrant la valeur courante. Quand la tonalité d'origine
/// ([originalKey]) est connue, la valeur centrale affiche la tonalité obtenue
/// (ex. « D ») plutôt que le nombre de demi-tons. Le parent porte l'état et
/// reçoit le delta à appliquer via [onTranspose].
///
/// Utilisé seul dans le panneau de transposition ([showChordProTransposeSheet])
/// comme dans le panneau d'options de la visionneuse de chant.
class ChordProTransposeControls extends StatelessWidget {
  const ChordProTransposeControls({
    super.key,
    required this.semitones,
    required this.onTranspose,
    this.originalKey,
    this.enabled = true,
  });

  final int semitones;
  final ValueChanged<int> onTranspose;

  /// Tonalité d'origine du chant (`{key:}`), si connue. Quand elle l'est, la
  /// valeur centrale affiche la tonalité obtenue après transposition au lieu du
  /// nombre de demi-tons ; sinon on retombe sur « +X / -X ».
  final String? originalKey;

  /// Quand `false`, les contrôles restent affichés mais grisés et inactifs
  /// (ex. transposition non pertinente sur la vue Partition).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // onPressed null désactive et grise automatiquement les IconButton.
    final disabledColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    // Tonalité obtenue après transposition, si la tonalité d'origine est connue.
    final keyLabel = transposedKeyLabel(originalKey, semitones);
    return Row(
      children: [
        Text(
          'Transposition',
          style: theme.textTheme.titleSmall?.copyWith(
            color: enabled ? null : disabledColor,
          ),
        ),
        const Spacer(),
        IconButton.filledTonal(
          tooltip: 'Transposer -1',
          icon: const Icon(Icons.remove),
          onPressed: enabled ? () => onTranspose(-1) : null,
        ),
        SizedBox(
          width: 56,
          child: Text(
            keyLabel ?? (semitones > 0 ? '+$semitones' : '$semitones'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: enabled ? null : disabledColor,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Transposer +1',
          icon: const Icon(Icons.add),
          onPressed: enabled ? () => onTranspose(1) : null,
        ),
      ],
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({
    required this.section,
    this.heading,
    this.isChorus = false,
  });

  final Section section;
  final String? heading;
  final bool isChorus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Les lignes sont espacées par intercalation (et non par une marge de fin
    // sur chaque ligne) : ainsi une section n'a aucun espace résiduel en bas,
    // ce qui rend l'écart entre sections identique partout.
    final children = <Widget>[
      if (heading != null && heading!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            heading!.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
    ];
    // On ignore les lignes structurées vides (issues des lignes blanches du
    // fichier source) : elles n'ajouteraient que du vide en hauteur.
    final lines = section.lines
        .where((l) => !(l.kind == LineKind.structured && l.tokens.isEmpty))
        .toList();
    for (var i = 0; i < lines.length; i++) {
      if (i > 0) children.add(const SizedBox(height: 8));
      children.add(_LineView(line: lines[i]));
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    // Le refrain est une boîte : son padding interne est de l'air *dans* la
    // boîte, pas de l'espace entre sections. Le couplet (sans boîte) n'a donc
    // pas de padding vertical, sinon il gonflerait l'écart de façon invisible.
    // L'écart entre sections est porté uniquement par le SizedBox de
    // _buildSections, ce qui le rend symétrique.
    if (isChorus) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.06),
          border: Border(
            left: BorderSide(color: theme.colorScheme.primary, width: 3),
          ),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: content,
      );
    }

    return Padding(padding: const EdgeInsets.only(left: 15), child: content);
  }
}

class _LineView extends StatelessWidget {
  const _LineView({required this.line});

  final Line line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (line.kind) {
      case LineKind.structured:
        final segments = _segments(line.tokens);
        final hasChords = segments.any((s) => s.chord.isNotEmpty);
        // Ligne sans accord : pas de ligne d'accords réservée.
        if (!hasChords) {
          return Text(
            segments.map((s) => s.text).join(),
            style: theme.textTheme.bodyLarge,
          );
        }
        // Le retour à la ligne ne se fait qu'entre les mots : chaque mot
        // (syllabes contiguës) reste insécable.
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            for (final word in _words(segments)) _WordView(pieces: word),
          ],
        );
      case LineKind.comment:
        return Text(
          line.comment ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        );
      case LineKind.verbatim:
        return Text(
          line.verbatim ?? '',
          style: const TextStyle(fontFamily: 'monospace'),
        );
      case LineKind.image:
      case LineKind.layoutBreak:
        return const SizedBox.shrink();
    }
  }
}

typedef _Pair = ({String chord, String text});

/// Apparie chaque accord avec la syllabe qui le suit. Un accord sans parole
/// (fin de ligne, accords consécutifs) devient un segment au texte vide ;
/// un texte sans accord devient un segment à l'accord vide.
List<_Pair> _segments(List<InlineToken> tokens) {
  final segments = <_Pair>[];
  var pendingChord = '';
  var hasChord = false;

  void flushChordOnly() {
    if (hasChord) {
      segments.add((chord: pendingChord, text: ''));
      pendingChord = '';
      hasChord = false;
    }
  }

  for (final token in tokens) {
    switch (token) {
      case ChordToken():
        flushChordOnly();
        pendingChord = token.chord?.toString() ?? token.raw;
        hasChord = true;
      case AnnotationToken():
        flushChordOnly();
        pendingChord = token.text;
        hasChord = true;
      case TextToken():
        segments.add((chord: hasChord ? pendingChord : '', text: token.text));
        pendingChord = '';
        hasChord = false;
      case InlineDirectiveToken():
        break;
    }
  }
  flushChordOnly();
  return segments;
}

/// Regroupe les segments en mots insécables. Les fragments de texte sont
/// découpés sur les espaces : les syllabes contiguës (sans espace entre elles)
/// forment un même mot, l'accord restant attaché au début de sa syllabe.
List<List<_Pair>> _words(List<_Pair> segments) {
  final words = <List<_Pair>>[];
  var current = <_Pair>[];

  void closeWord() {
    if (current.isNotEmpty) {
      words.add(current);
      current = [];
    }
  }

  for (final segment in segments) {
    // Accord seul (sans parole) : mot autonome.
    if (segment.text.isEmpty) {
      closeWord();
      words.add([segment]);
      continue;
    }
    final chunks = segment.text.split(' ');
    var firstChunk = true;
    for (var i = 0; i < chunks.length; i++) {
      if (i > 0) closeWord(); // un espace séparait ce morceau du précédent
      final chunk = chunks[i];
      if (chunk.isEmpty) continue;
      current.add((chord: firstChunk ? segment.chord : '', text: chunk));
      firstChunk = false;
    }
  }
  closeWord();
  return words;
}

final _wordCharStart = RegExp(r'^[\p{L}\p{N}]', unicode: true);
final _wordCharEnd = RegExp(r'[\p{L}\p{N}]$', unicode: true);

/// Deux morceaux se joignent comme des syllabes (et méritent un tiret de
/// continuation) quand le premier finit et le second commence par une
/// lettre/chiffre. Évite un tiret parasite devant une ponctuation (« mot-, »).
bool _joinsAsSyllables(String left, String right) =>
    _wordCharEnd.hasMatch(left) && _wordCharStart.hasMatch(right);

/// Affiche un mot insécable : ses syllabes sont alignées côte à côte et ne
/// peuvent pas être séparées par un retour à la ligne.
class _WordView extends StatelessWidget {
  const _WordView({required this.pieces});

  final List<_Pair> pieces;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < pieces.length; i++)
          _Segment(
            chord: pieces[i].chord,
            text: pieces[i].text,
            // Tiret de continuation seulement entre deux vraies syllabes (pas
            // devant une ponctuation qui termine le mot).
            continuesWord:
                i < pieces.length - 1 &&
                _joinsAsSyllables(pieces[i].text, pieces[i + 1].text),
          ),
      ],
    );
  }
}

/// Hauteur réservée pour la ligne d'accords, afin que toutes les paroles
/// d'une même ligne partagent la même ligne de base.
const double _chordRowHeight = 22;

/// Espace minimal à droite d'un accord, pour que deux accords rapprochés ne se
/// touchent pas même au-dessus d'une parole étroite.
const double _chordGap = 8;

/// Un fragment de parole avec son accord positionné au-dessus de son début.
///
/// La largeur du segment est dictée par la parole : l'accord flotte par-dessus,
/// aligné à gauche, et peut déborder à droite sans étirer le texte.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.chord,
    required this.text,
    this.continuesWord = false,
  });

  final String chord;
  final String text;

  /// Vrai quand cette syllabe est suivie d'une autre du même mot (mot découpé
  /// par les accords) : on ajoute alors un tiret de continuation.
  final bool continuesWord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chordStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );
    final textStyle = theme.textTheme.bodyLarge;

    // Parole affichée : tiret de continuation si le mot se poursuit après.
    final lyric = continuesWord && text.isNotEmpty ? '$text-' : text;

    final chordWidget = chord.isEmpty
        ? null
        : SizedBox(
            height: _chordRowHeight,
            child: Text(chord, style: chordStyle, softWrap: false),
          );

    // Mot sans accord : pas de bande réservée, juste la parole. Aligné par le
    // bas avec ses voisins, sa ligne de base reste celle de la ligne.
    if (chordWidget == null) {
      return Text(
        lyric.isEmpty ? ' ' : lyric,
        style: textStyle,
        softWrap: false,
      );
    }

    // Accord seul (sans parole) : il occupe sa propre largeur.
    if (text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chordWidget,
            Text(' ', style: textStyle),
          ],
        ),
      );
    }

    // Parole avec accord : la largeur est le max entre la parole et l'accord
    // (+ un petit espace) pour que deux accords rapprochés ne se chevauchent
    // pas. L'accord reste aligné au début de sa parole ; s'il est plus large,
    // il pousse la suite vers la droite — l'alignement accord/parole est
    // préservé, seuls les endroits trop serrés s'écartent.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: _chordGap),
          child: chordWidget,
        ),
        Text(lyric, style: textStyle, softWrap: false),
      ],
    );
  }
}
