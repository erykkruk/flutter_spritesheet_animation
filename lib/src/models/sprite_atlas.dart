import 'dart:convert';

import 'package:flutter/services.dart';

import 'sprite_animation_data.dart';
import 'sprite_frame.dart';

/// Parsed spritesheet atlas containing frame definitions and named animations.
///
/// Supports two common JSON formats:
/// - **TexturePacker** (hash or array) - frames with optional `frameTags`
/// - **Aseprite** - array-based frames with `frameTags` for named animations
///
/// Auto-detects the format from the JSON structure.
///
/// ```dart
/// final atlas = SpriteAtlas.fromJson(jsonString);
/// final idle = atlas.getAnimation('idle');
/// ```
class SpriteAtlas {
  /// Creates a sprite atlas from pre-parsed data.
  const SpriteAtlas({
    required this.frames,
    required this.animations,
    this.imageWidth,
    this.imageHeight,
  });

  /// Parses a sprite atlas from a JSON string.
  ///
  /// Auto-detects between TexturePacker (hash/array) and Aseprite formats.
  ///
  /// Throws [FormatException] if the JSON structure is not recognized.
  factory SpriteAtlas.fromJson(String jsonString) {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException {
      throw const FormatException('Invalid JSON: could not parse atlas file.');
    }

    if (!json.containsKey('frames')) {
      throw const FormatException(
        'Invalid atlas format: missing "frames" key.',
      );
    }

    final framesData = json['frames'];
    final List<SpriteFrame> frames;

    if (framesData is Map<String, dynamic>) {
      // TexturePacker hash format: { "frames": { "frame_name": { ... } } }
      frames = _parseHashFrames(framesData);
    } else if (framesData is List) {
      // Array format (Aseprite or TexturePacker array)
      frames = _parseArrayFrames(framesData);
    } else {
      throw const FormatException(
        'Invalid atlas format: "frames" must be an object or array.',
      );
    }

    // Parse image size from meta
    int? imageWidth;
    int? imageHeight;
    final meta = json['meta'] as Map<String, dynamic>?;
    if (meta != null) {
      final size = meta['size'] as Map<String, dynamic>?;
      if (size != null) {
        imageWidth = (size['w'] as num?)?.toInt();
        imageHeight = (size['h'] as num?)?.toInt();
      }
    }

    // Parse named animations from frameTags
    final animations = <String, SpriteAnimationData>{};
    final frameTags = meta?['frameTags'] as List?;
    if (frameTags != null) {
      for (final tag in frameTags) {
        final tagMap = tag as Map<String, dynamic>;
        final name = tagMap['name'] as String;
        final from = (tagMap['from'] as num).toInt();
        final to = (tagMap['to'] as num).toInt();

        if (from >= 0 && to < frames.length && from <= to) {
          animations[name] = SpriteAnimationData(
            name: name,
            frames: frames.sublist(from, to + 1),
          );
        }
      }
    }

    // If no frameTags, create a default animation from all frames
    if (animations.isEmpty && frames.isNotEmpty) {
      animations['default'] = SpriteAnimationData(
        name: 'default',
        frames: frames,
      );
    }

    return SpriteAtlas(
      frames: frames,
      animations: animations,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  /// Loads and parses a sprite atlas from a Flutter asset path.
  ///
  /// ```dart
  /// final atlas = await SpriteAtlas.fromAsset('assets/spritesheet.json');
  /// ```
  static Future<SpriteAtlas> fromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    return SpriteAtlas.fromJson(jsonString);
  }

  /// All frames in the atlas, in order.
  final List<SpriteFrame> frames;

  /// Named animations parsed from `frameTags`.
  ///
  /// If no frameTags exist, contains a single 'default' animation
  /// with all frames.
  final Map<String, SpriteAnimationData> animations;

  /// Width of the source image in pixels (from meta).
  final int? imageWidth;

  /// Height of the source image in pixels (from meta).
  final int? imageHeight;

  /// Returns the animation data for the given [name].
  ///
  /// Throws [ArgumentError] if no animation with that name exists.
  SpriteAnimationData getAnimation(String name) {
    final animation = animations[name];
    if (animation == null) {
      throw ArgumentError(
        'Animation "$name" not found. '
        'Available: ${animations.keys.join(', ')}',
      );
    }
    return animation;
  }

  /// Returns the list of available animation names.
  List<String> get animationNames => animations.keys.toList();

  @override
  String toString() =>
      'SpriteAtlas(frames: ${frames.length}, '
      'animations: ${animations.keys.join(', ')})';
}

// ---------------------------------------------------------------------------
// Private parsing helpers
// ---------------------------------------------------------------------------

/// Parses TexturePacker hash format where frames is `Map<String, dynamic>`.
List<SpriteFrame> _parseHashFrames(Map<String, dynamic> framesMap) {
  return [
    for (final entry in framesMap.entries)
      _parseSingleFrame(entry.value as Map<String, dynamic>),
  ];
}

/// Parses array format where frames is a [List] (Aseprite or TexturePacker array).
List<SpriteFrame> _parseArrayFrames(List<dynamic> framesList) {
  return [
    for (final item in framesList)
      _parseSingleFrame(item as Map<String, dynamic>),
  ];
}

/// Parses a single frame entry from either format.
SpriteFrame _parseSingleFrame(Map<String, dynamic> frameData) {
  final frame = frameData['frame'] as Map<String, dynamic>;
  final x = (frame['x'] as num).toDouble();
  final y = (frame['y'] as num).toDouble();
  final w = (frame['w'] as num).toDouble();
  final h = (frame['h'] as num).toDouble();

  final rotated = frameData['rotated'] as bool? ?? false;
  final trimmed = frameData['trimmed'] as bool? ?? false;

  Size? sourceSize;
  final sourceSizeData = frameData['sourceSize'] as Map<String, dynamic>?;
  if (sourceSizeData != null) {
    sourceSize = Size(
      (sourceSizeData['w'] as num).toDouble(),
      (sourceSizeData['h'] as num).toDouble(),
    );
  }

  Offset offset = Offset.zero;
  final spriteSourceSize =
      frameData['spriteSourceSize'] as Map<String, dynamic>?;
  if (spriteSourceSize != null) {
    offset = Offset(
      (spriteSourceSize['x'] as num).toDouble(),
      (spriteSourceSize['y'] as num).toDouble(),
    );
  }

  final duration = (frameData['duration'] as num?)?.toInt();

  return SpriteFrame(
    rect: Rect.fromLTWH(x, y, w, h),
    duration: duration,
    sourceSize: sourceSize,
    offset: offset,
    rotated: rotated,
    trimmed: trimmed,
  );
}
