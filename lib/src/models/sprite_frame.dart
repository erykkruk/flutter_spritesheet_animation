import 'dart:ui';

/// A single frame within a spritesheet.
///
/// Describes the rectangular region of the source image that contains
/// this frame's pixel data, plus optional duration and trimming info.
class SpriteFrame {
  /// Creates a sprite frame.
  const SpriteFrame({
    required this.rect,
    this.duration,
    this.sourceSize,
    this.offset = Offset.zero,
    this.rotated = false,
    this.trimmed = false,
  });

  /// The rectangle region within the spritesheet image.
  final Rect rect;

  /// Duration of this frame in milliseconds. Overrides global FPS when set.
  final int? duration;

  /// Original size before trimming. Used for proper positioning.
  final Size? sourceSize;

  /// Offset from the top-left of the source size to the trimmed rect.
  final Offset offset;

  /// Whether this frame is rotated 90 degrees clockwise in the atlas.
  final bool rotated;

  /// Whether this frame has been trimmed from its original size.
  final bool trimmed;

  /// The display width of this frame (accounts for rotation).
  double get width => rotated ? rect.height : rect.width;

  /// The display height of this frame (accounts for rotation).
  double get height => rotated ? rect.width : rect.height;

  @override
  String toString() => 'SpriteFrame(rect: $rect, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpriteFrame &&
          runtimeType == other.runtimeType &&
          rect == other.rect &&
          duration == other.duration &&
          sourceSize == other.sourceSize &&
          offset == other.offset &&
          rotated == other.rotated &&
          trimmed == other.trimmed;

  @override
  int get hashCode =>
      Object.hash(rect, duration, sourceSize, offset, rotated, trimmed);
}
