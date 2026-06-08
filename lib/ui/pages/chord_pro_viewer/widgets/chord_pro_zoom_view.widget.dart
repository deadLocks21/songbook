import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/widgets/cached_chord_pro_viewer.widget.dart';

/// Bornes du zoom de texte ChordPro, partagées entre le pinch et les boutons.
const double minChordProScale = 0.6;
const double maxChordProScale = 3.0;
const double chordProScaleStep = 0.1;

/// Enveloppe [CachedChordProViewer] d'un geste unique qui gère **à la fois** le
/// défilement (glisser) et le zoom du texte (pincer) — un seul `GestureDetector`
/// pour éviter tout conflit entre les deux. Le défilement est piloté
/// manuellement via un [ScrollController] (la vue interne n'a plus de physique
/// propre), avec une inertie simple au relâchement.
///
/// Le facteur de zoom ([textScale]) est porté par l'appelant (état éphémère de
/// la page) pour que les boutons du panneau d'options et le pincement agissent
/// sur la même valeur.
class ChordProZoomView extends StatefulWidget {
  final String songId;
  final String chordProUrl;
  final int semitones;
  final ValueChanged<String?>? onOriginalKey;
  final double textScale;
  final ValueChanged<double> onTextScaleChanged;

  const ChordProZoomView({
    super.key,
    required this.songId,
    required this.chordProUrl,
    required this.textScale,
    required this.onTextScaleChanged,
    this.semitones = 0,
    this.onOriginalKey,
  });

  @override
  State<ChordProZoomView> createState() => _ChordProZoomViewState();
}

class _ChordProZoomViewState extends State<ChordProZoomView> {
  final ScrollController _scrollController = ScrollController();
  double _scaleStart = 1.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _scaleStart = widget.textScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // Pincement (2 doigts) : zoom. Le facteur 1.0 correspond à un simple
    // glissement, qui ne doit pas modifier le zoom.
    if (details.scale != 1.0) {
      final next = (_scaleStart * details.scale).clamp(
        minChordProScale,
        maxChordProScale,
      );
      if (next != widget.textScale) widget.onTextScaleChanged(next);
    }
    // Défilement (1 ou 2 doigts) : on suit le déplacement du point focal.
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      _scrollController.jumpTo(
        (position.pixels - details.focalPointDelta.dy).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    }
  }

  /// Souris/trackpad (desktop & web) : la molette fait défiler, et
  /// Ctrl/Cmd + molette zoome (le pinch trackpad du web arrive aussi sous cette
  /// forme). Nécessaire car le défilement est piloté manuellement.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final keyboard = HardwareKeyboard.instance;
    final zooming = keyboard.isControlPressed || keyboard.isMetaPressed;

    if (zooming) {
      final factor = 1 - event.scrollDelta.dy * 0.0015;
      final next = (widget.textScale * factor).clamp(
        minChordProScale,
        maxChordProScale,
      );
      if (next != widget.textScale) widget.onTextScaleChanged(next);
    } else if (_scrollController.hasClients) {
      final position = _scrollController.position;
      _scrollController.jumpTo(
        (position.pixels + event.scrollDelta.dy).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_scrollController.hasClients) return;
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (velocity.abs() < 200) return;
    // Inertie simple : on prolonge le mouvement proportionnellement à la vitesse.
    final position = _scrollController.position;
    final target = (position.pixels - velocity * 0.25).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.decelerate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: CachedChordProViewer(
          songId: widget.songId,
          chordProUrl: widget.chordProUrl,
          semitones: widget.semitones,
          onOriginalKey: widget.onOriginalKey,
          textScale: widget.textScale,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}
