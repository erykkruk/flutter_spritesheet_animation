import 'sprite_frame.dart';

/// Describes a named animation sequence within a spritesheet atlas.
///
/// Contains the ordered list of frames and optional metadata like
/// default FPS and looping behavior.
class SpriteAnimationData {
  /// Creates a sprite animation data object.
  const SpriteAnimationData({
    required this.name,
    required this.frames,
    this.fps,
    this.loop = true,
  });

  /// The name of this animation (e.g., 'idle', 'walk', 'attack').
  final String name;

  /// Ordered list of frames in this animation.
  final List<SpriteFrame> frames;

  /// Default frames per second. Can be overridden by the controller.
  final double? fps;

  /// Whether this animation loops by default.
  final bool loop;

  /// Total number of frames in this animation.
  int get frameCount => frames.length;

  @override
  String toString() =>
      'SpriteAnimationData(name: $name, frames: $frameCount, fps: $fps)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpriteAnimationData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          frames == other.frames &&
          fps == other.fps &&
          loop == other.loop;

  @override
  int get hashCode => Object.hash(name, frames, fps, loop);
}
