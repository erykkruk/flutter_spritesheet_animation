/// Playback direction mode for sprite animations.
enum PlayMode {
  /// Plays frames from first to last.
  forward,

  /// Plays frames from last to first.
  reverse,

  /// Alternates between forward and reverse each cycle.
  pingPong,
}

/// Convenience checks for [PlayMode].
extension PlayModeX on PlayMode {
  /// Whether playback runs first-to-last.
  bool get isForward => this == PlayMode.forward;

  /// Whether playback runs last-to-first.
  bool get isReverse => this == PlayMode.reverse;

  /// Whether playback alternates direction each cycle.
  bool get isPingPong => this == PlayMode.pingPong;
}
