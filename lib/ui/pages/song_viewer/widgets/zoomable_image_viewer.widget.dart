import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Widget de visualisation d'images avec zoom et pan.
/// Affiche une liste d'images horizontalement avec support du pinch-to-zoom,
/// du pan, et du double-tap pour reset.
class ZoomableImageViewer extends StatefulWidget {
  final List<String> imagePaths;

  const ZoomableImageViewer({super.key, required this.imagePaths});

  @override
  State<ZoomableImageViewer> createState() => _ZoomableImageViewerState();
}

class _ZoomableImageViewerState extends State<ZoomableImageViewer> {
  final TransformationController _transformationController =
      TransformationController();
  List<Size>? _imageSizes;
  bool _isLoading = true;

  // Dimensions du viewport et contenu pour le clamping
  double _viewportWidth = 0;
  double _viewportHeight = 0;
  double _contentWidth = 0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_clampTranslation);
    _loadImageSizes();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_clampTranslation);
    _transformationController.dispose();
    super.dispose();
  }

  /// Charge les dimensions de toutes les images de manière asynchrone.
  Future<void> _loadImageSizes() async {
    if (widget.imagePaths.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final sizes = <Size>[];
    for (final path in widget.imagePaths) {
      try {
        final bytes = await File(path).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        sizes.add(
          Size(frame.image.width.toDouble(), frame.image.height.toDouble()),
        );
        codec.dispose();
      } catch (e) {
        // En cas d'erreur, on utilise une taille par défaut
        sizes.add(const Size(1, 1));
      }
    }

    if (mounted) {
      setState(() {
        _imageSizes = sizes;
        _isLoading = false;
      });
    }
  }

  /// Calcule la largeur totale du contenu à scale 1.0
  double _calculateTotalWidth(double viewportHeight) {
    if (_imageSizes == null) return 0;

    double totalWidth = 0;
    for (final size in _imageSizes!) {
      final aspectRatio = size.width / size.height;
      totalWidth += viewportHeight * aspectRatio;
    }
    return totalWidth;
  }

  /// Calcule le scale minimum pour éviter de zoomer dans le vide.
  double _calculateMinScale(double viewportWidth, double contentWidth) {
    if (contentWidth <= 0) return 1.0;

    // Si le contenu tient dans l'écran, pas de dezoom possible
    if (contentWidth <= viewportWidth) {
      return 1.0;
    }

    // Sinon, permettre de tout voir
    return viewportWidth / contentWidth;
  }

  /// Réinitialise le zoom à la valeur initiale.
  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  /// Contraint la translation pour éviter de montrer du vide.
  void _clampTranslation() {
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    final scaledContentWidth = _contentWidth * scale;
    final scaledContentHeight = _viewportHeight * scale;

    // Extraire la translation actuelle
    double tx = matrix.getTranslation().x;
    double ty = matrix.getTranslation().y;

    // Clamping horizontal
    if (scaledContentWidth <= _viewportWidth) {
      // Contenu plus petit que viewport : centrer horizontalement
      tx = (_viewportWidth - scaledContentWidth) / 2;
    } else {
      // Contenu plus grand : limiter le pan
      final minTx = _viewportWidth - scaledContentWidth;
      final maxTx = 0.0;
      tx = tx.clamp(minTx, maxTx);
    }

    // Clamping vertical
    if (scaledContentHeight <= _viewportHeight) {
      // Contenu plus petit que viewport : centrer verticalement
      ty = (_viewportHeight - scaledContentHeight) / 2;
    } else {
      // Contenu plus grand : limiter le pan
      final minTy = _viewportHeight - scaledContentHeight;
      final maxTy = 0.0;
      ty = ty.clamp(minTy, maxTy);
    }

    // Appliquer la correction si nécessaire
    final currentTx = matrix.getTranslation().x;
    final currentTy = matrix.getTranslation().y;
    if ((tx - currentTx).abs() > 0.1 || (ty - currentTy).abs() > 0.1) {
      final correctedMatrix = Matrix4.identity()
        ..setEntry(0, 3, tx)
        ..setEntry(1, 3, ty)
        ..setEntry(0, 0, scale)
        ..setEntry(1, 1, scale)
        ..setEntry(2, 2, scale);
      _transformationController.value = correctedMatrix;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Stocker les dimensions pour le clamping
        _viewportWidth = constraints.maxWidth;
        _viewportHeight = constraints.maxHeight;
        _contentWidth = _calculateTotalWidth(_viewportHeight);
        final minScale = _calculateMinScale(_viewportWidth, _contentWidth);

        return GestureDetector(
          onDoubleTap: _resetZoom,
          child: InteractiveViewer.builder(
            transformationController: _transformationController,
            minScale: minScale,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            builder: (context, quad) {
              return SizedBox(
                height: _viewportHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildImageWidgets(_viewportHeight),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildImageWidgets(double height) {
    return widget.imagePaths.asMap().entries.map((entry) {
      final index = entry.key;
      final path = entry.value;

      // Calculer la largeur basée sur l'aspect ratio réel
      double? imageWidth;
      if (_imageSizes != null && index < _imageSizes!.length) {
        final size = _imageSizes![index];
        imageWidth = height * (size.width / size.height);
      }

      return SizedBox(
        width: imageWidth,
        height: height,
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }).toList();
  }
}
