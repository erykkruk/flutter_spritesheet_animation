import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/sprite_animation_controller.dart';
import '../models/models.dart';

/// A widget that renders animated sprites from a spritesheet image.
///
/// Supports two modes:
///
/// - **Grid mode** ([SpriteAnimation.grid]): Frames laid out in a uniform grid.
/// - **Atlas mode** ([SpriteAnimation.atlas]): Frames defined by a JSON atlas
///   (TexturePacker or Aseprite format) with optional named animations.
///
/// ```dart
/// SpriteAnimation.grid(
///   image: AssetImage('assets/explosion.png'),
///   columns: 8,
///   rows: 4,
///   frameCount: 30,
///   fps: 24,
/// )
/// ```
class SpriteAnimation extends StatefulWidget {
  /// Creates a grid-based sprite animation.
  ///
  /// Frames are assumed to be arranged in a uniform grid of [columns] x [rows].
  /// [frameCount] defaults to `columns * rows` if not specified.
  const SpriteAnimation.grid({
    super.key,
    required this.image,
    required this.columns,
    required this.rows,
    this.frameCount,
    this.fps = 12,
    this.autoPlay = true,
    this.loop = true,
    this.mode = PlayMode.forward,
    this.blendMode = BlendMode.srcOver,
    this.onFrame,
    this.onComplete,
    this.controller,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  }) : atlas = null,
       animation = null;

  /// Creates an atlas-based sprite animation.
  ///
  /// Frames are defined by a [SpriteAtlas]. If the atlas contains named
  /// animations (frameTags), use [animation] to select one.
  const SpriteAnimation.atlas({
    super.key,
    required this.image,
    required this.atlas,
    this.animation,
    this.fps = 12,
    this.autoPlay = true,
    this.loop = true,
    this.mode = PlayMode.forward,
    this.blendMode = BlendMode.srcOver,
    this.onFrame,
    this.onComplete,
    this.controller,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  }) : columns = null,
       rows = null,
       frameCount = null;

  /// The spritesheet image provider.
  final ImageProvider image;

  /// Number of columns in the grid (grid mode only).
  final int? columns;

  /// Number of rows in the grid (grid mode only).
  final int? rows;

  /// Total number of frames. Defaults to `columns * rows` in grid mode.
  final int? frameCount;

  /// The parsed atlas data (atlas mode only).
  final SpriteAtlas? atlas;

  /// Named animation to play from the atlas (atlas mode only).
  final String? animation;

  /// Frames per second.
  final double fps;

  /// Whether to start playing automatically.
  final bool autoPlay;

  /// Whether to loop the animation.
  final bool loop;

  /// Playback direction mode.
  final PlayMode mode;

  /// Blend mode used when painting the sprite.
  final BlendMode blendMode;

  /// Called when the frame changes.
  final ValueChanged<int>? onFrame;

  /// Called when a non-looping animation completes.
  final VoidCallback? onComplete;

  /// Optional external controller for programmatic playback control.
  final SpriteAnimationController? controller;

  /// How the sprite should be inscribed into the available space.
  final BoxFit fit;

  /// Fixed width. If null, sizes to parent constraints.
  final double? width;

  /// Fixed height. If null, sizes to parent constraints.
  final double? height;

  /// Whether this is a grid-based animation.
  bool get isGrid => columns != null && rows != null;

  @override
  State<SpriteAnimation> createState() => _SpriteAnimationState();
}

class _SpriteAnimationState extends State<SpriteAnimation>
    with SingleTickerProviderStateMixin {
  late SpriteAnimationController _controller;
  bool _ownsController = false;
  ui.Image? _loadedImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  // Pre-computed grid frame rects — avoids recalculation during paint.
  List<Rect>? _gridRects;

  // Reusable Paint object — avoids allocation per frame.
  final Paint _spritePaint = Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant SpriteAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller change
    if (widget.controller != oldWidget.controller) {
      _disposeController();
      _initController();
    }

    // Handle image change
    if (widget.image != oldWidget.image) {
      _gridRects = null;
      _resolveImage();
    }

    // Handle config changes
    _controller.fps = widget.fps;
    _controller.mode = widget.mode;
    _controller.loop = widget.loop;

    // Handle animation name change (atlas mode)
    if (widget.atlas != null && widget.animation != oldWidget.animation) {
      final name = widget.animation ?? widget.atlas!.animationNames.first;
      _controller.setAnimation(name, atlas: widget.atlas!);
    }

    // Invalidate grid rects if grid config changed
    if (widget.columns != oldWidget.columns ||
        widget.rows != oldWidget.rows ||
        widget.frameCount != oldWidget.frameCount) {
      _gridRects = null;
    }
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = SpriteAnimationController(
        fps: widget.fps,
        mode: widget.mode,
        loop: widget.loop,
        autoPlay: widget.autoPlay,
      );
      _ownsController = true;
    }

    _controller.attach(this);
    _controller.onFrame = widget.onFrame;
    _controller.onComplete = widget.onComplete;
    _controller.addListener(_onControllerUpdate);

    _setupFrames();
  }

  void _setupFrames() {
    if (widget.isGrid) {
      final total = widget.frameCount ?? (widget.columns! * widget.rows!);
      _controller.setupGrid(totalFrames: total);
    } else if (widget.atlas != null) {
      _controller.setupAtlas(
        atlas: widget.atlas!,
        animationName: widget.animation,
      );
    }
  }

  void _disposeController() {
    _controller.removeListener(_onControllerUpdate);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // Grid rect pre-computation
  // ---------------------------------------------------------------------------

  /// Pre-computes all grid source rects once when the image loads.
  /// This moves division and multiplication out of the paint loop.
  void _buildGridRects() {
    final image = _loadedImage;
    final columns = widget.columns;
    final rows = widget.rows;
    if (image == null || columns == null || rows == null) return;

    final frameWidth = image.width / columns;
    final frameHeight = image.height / rows;
    final total = widget.frameCount ?? (columns * rows);

    _gridRects = List<Rect>.generate(total, (i) {
      final col = i % columns;
      final row = i ~/ columns;
      return Rect.fromLTWH(
        col * frameWidth,
        row * frameHeight,
        frameWidth,
        frameHeight,
      );
    }, growable: false);
  }

  // ---------------------------------------------------------------------------
  // Image loading
  // ---------------------------------------------------------------------------

  void _resolveImage() {
    _disposeImageStream();

    final imageConfig = createLocalImageConfiguration(context);
    _imageStream = widget.image.resolve(imageConfig);
    _imageStreamListener = ImageStreamListener(
      _onImageLoaded,
      onError: _onImageError,
    );
    _imageStream!.addListener(_imageStreamListener!);
  }

  void _onImageLoaded(ImageInfo info, bool synchronousCall) {
    if (mounted) {
      setState(() {
        _loadedImage = info.image;
        _gridRects = null;
        if (widget.isGrid) {
          _buildGridRects();
        }
      });
    }
  }

  void _onImageError(Object error, StackTrace? stackTrace) {
    debugPrint('SpriteAnimation: Failed to load image: $error');
  }

  void _disposeImageStream() {
    if (_imageStreamListener != null && _imageStream != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageStreamListener = null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_loadedImage == null) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    _spritePaint.blendMode = widget.blendMode;

    return CustomPaint(
      size: Size(
        widget.width ?? double.infinity,
        widget.height ?? double.infinity,
      ),
      painter: _SpritePainter(
        image: _loadedImage!,
        frame: _controller.currentFrame,
        gridRects: _gridRects,
        frameData: _controller.currentFrameData,
        spritePaint: _spritePaint,
        fit: widget.fit,
      ),
    );
  }

  @override
  void dispose() {
    _disposeImageStream();
    _disposeController();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Custom Painter
// ---------------------------------------------------------------------------

class _SpritePainter extends CustomPainter {
  _SpritePainter({
    required this.image,
    required this.frame,
    this.gridRects,
    this.frameData,
    required this.spritePaint,
    required this.fit,
  });

  final ui.Image image;
  final int frame;
  final List<Rect>? gridRects;
  final SpriteFrame? frameData;
  final Paint spritePaint;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect srcRect;

    if (frameData != null) {
      // Atlas mode: use pre-defined frame rect (already computed at parse time)
      srcRect = frameData!.rect;
    } else if (gridRects != null && frame < gridRects!.length) {
      // Grid mode: use pre-computed rect (no math in paint loop)
      srcRect = gridRects![frame];
    } else {
      return;
    }

    // Calculate destination rect based on fit
    final fittedSizes = applyBoxFit(
      fit,
      Size(srcRect.width, srcRect.height),
      size,
    );
    final destinationRect = Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & size,
    );

    canvas.drawImageRect(image, srcRect, destinationRect, spritePaint);
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) =>
      frame != oldDelegate.frame ||
      image != oldDelegate.image ||
      spritePaint.blendMode != oldDelegate.spritePaint.blendMode;
}
