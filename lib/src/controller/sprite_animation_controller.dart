import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../models/models.dart';

/// Controls playback of sprite animations.
///
/// Manages frame advancement via a [Ticker], supporting play/pause/stop,
/// frame seeking, playback modes, and FPS control.
///
/// Must be attached to a [TickerProvider] before use. The [SpriteAnimation]
/// widget handles this automatically. For standalone use, call [attach]
/// with a [TickerProvider].
///
/// ```dart
/// final controller = SpriteAnimationController();
/// controller.play();
/// controller.pause();
/// controller.stop();
/// controller.goToFrame(5);
/// controller.dispose();
/// ```
class SpriteAnimationController extends ChangeNotifier {
  /// Creates a sprite animation controller.
  ///
  /// Optionally accepts initial [fps], [mode], and [loop] settings.
  SpriteAnimationController({
    double fps = 12,
    PlayMode mode = PlayMode.forward,
    bool loop = true,
    bool autoPlay = true,
  }) : _fps = fps,
       _mode = mode,
       _loop = loop,
       _autoPlay = autoPlay;

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  double _fps;
  PlayMode _mode;
  bool _loop;
  final bool _autoPlay;

  /// Frames per second.
  double get fps => _fps;
  set fps(double value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'fps', 'Must be positive.');
    }
    if (_fps != value) {
      _fps = value;
      notifyListeners();
    }
  }

  /// Playback direction mode.
  PlayMode get mode => _mode;
  set mode(PlayMode value) {
    if (_mode != value) {
      _mode = value;
      notifyListeners();
    }
  }

  /// Whether the animation loops.
  bool get loop => _loop;
  set loop(bool value) {
    if (_loop != value) {
      _loop = value;
      notifyListeners();
    }
  }

  /// Whether playback starts automatically when attached.
  bool get autoPlay => _autoPlay;

  // ---------------------------------------------------------------------------
  // Playback state
  // ---------------------------------------------------------------------------

  int _currentFrame = 0;
  bool _isPlaying = false;
  bool _isForward = true;
  int _totalFrames = 0;
  String? _animationName;
  List<SpriteFrame>? _frames;

  Ticker? _ticker;
  Duration _previousElapsed = Duration.zero;
  Duration _accumulatedTime = Duration.zero;

  /// The index of the currently displayed frame.
  int get currentFrame => _currentFrame;

  /// Whether the animation is currently playing.
  bool get isPlaying => _isPlaying;

  /// Total number of frames in the current animation.
  int get totalFrames => _totalFrames;

  /// Name of the current animation (atlas mode only).
  String? get animationName => _animationName;

  /// The current frame data, if frames are loaded.
  SpriteFrame? get currentFrameData =>
      _frames != null && _currentFrame < _frames!.length
      ? _frames![_currentFrame]
      : null;

  // ---------------------------------------------------------------------------
  // Callbacks
  // ---------------------------------------------------------------------------

  /// Called when the frame changes. Receives the new frame index.
  ValueChanged<int>? onFrame;

  /// Called when a non-looping animation completes.
  VoidCallback? onComplete;

  // ---------------------------------------------------------------------------
  // Ticker management
  // ---------------------------------------------------------------------------

  /// Attaches this controller to a [TickerProvider] for frame scheduling.
  void attach(TickerProvider vsync) {
    _ticker?.dispose();
    _ticker = vsync.createTicker(_onTick);
  }

  /// Sets up the frame data for grid-based animation.
  void setupGrid({required int totalFrames}) {
    _totalFrames = totalFrames;
    _frames = null;
    _animationName = null;
    _currentFrame = _currentFrame.clamp(0, _totalFrames - 1);
    if (_autoPlay && !_isPlaying && _ticker != null) {
      play();
    }
  }

  /// Sets up the frame data for atlas-based animation.
  void setupAtlas({required SpriteAtlas atlas, String? animationName}) {
    final name = animationName ?? atlas.animationNames.first;
    final animation = atlas.getAnimation(name);
    _frames = animation.frames;
    _totalFrames = animation.frameCount;
    _animationName = name;
    _currentFrame = 0;
    _isForward = true;

    if (animation.fps != null) {
      _fps = animation.fps!;
    }

    if (_autoPlay && !_isPlaying && _ticker != null) {
      play();
    }
    notifyListeners();
  }

  /// Switches to a named animation from the atlas.
  void setAnimation(String name, {required SpriteAtlas atlas}) {
    final animation = atlas.getAnimation(name);
    _frames = animation.frames;
    _totalFrames = animation.frameCount;
    _animationName = name;
    _currentFrame = 0;
    _isForward = true;

    if (animation.fps != null) {
      _fps = animation.fps!;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Playback controls
  // ---------------------------------------------------------------------------

  /// Starts or resumes playback.
  void play() {
    if (_totalFrames <= 0) return;
    if (_isPlaying) return;

    _isPlaying = true;
    _previousElapsed = Duration.zero;
    _accumulatedTime = Duration.zero;
    _ticker?.start();
    notifyListeners();
  }

  /// Pauses playback at the current frame.
  void pause() {
    if (!_isPlaying) return;

    _isPlaying = false;
    _ticker?.stop();
    _previousElapsed = Duration.zero;
    _accumulatedTime = Duration.zero;
    notifyListeners();
  }

  /// Stops playback and resets to frame 0.
  void stop() {
    if (_ticker?.isActive ?? false) {
      _ticker!.stop();
    }
    _isPlaying = false;
    _currentFrame = 0;
    _isForward = true;
    _previousElapsed = Duration.zero;
    _accumulatedTime = Duration.zero;
    notifyListeners();
  }

  /// Jumps to a specific frame index.
  void goToFrame(int frame) {
    final clamped = frame.clamp(0, _totalFrames - 1);
    if (_currentFrame != clamped) {
      _currentFrame = clamped;
      onFrame?.call(_currentFrame);
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Tick logic (accumulator pattern)
  // ---------------------------------------------------------------------------

  void _onTick(Duration elapsed) {
    if (_totalFrames <= 1 || !_isPlaying) return;

    final deltaTime = elapsed - _previousElapsed;
    _previousElapsed = elapsed;
    _accumulatedTime += deltaTime;

    final frameDurationMs = _currentFrameDurationMs;
    final frameDuration = Duration(milliseconds: frameDurationMs);

    var didAdvance = false;

    while (_accumulatedTime >= frameDuration && _isPlaying) {
      _accumulatedTime -= frameDuration;
      didAdvance = true;
      if (!_advanceSingleFrame()) break;
    }

    if (didAdvance) {
      notifyListeners();
    }
  }

  int get _currentFrameDurationMs {
    final frameData = currentFrameData;
    if (frameData?.duration != null && frameData!.duration! > 0) {
      return frameData.duration!;
    }
    return (1000 / _fps).round();
  }

  bool _advanceSingleFrame() {
    switch (_mode) {
      case PlayMode.forward:
        return _advanceForward();
      case PlayMode.reverse:
        return _advanceReverse();
      case PlayMode.pingPong:
        return _advancePingPong();
    }
  }

  bool _advanceForward() {
    if (_currentFrame >= _totalFrames - 1) {
      // At last frame - wrap or stop
      if (_loop) {
        _currentFrame = 0;
      } else {
        _complete();
        return false;
      }
    } else {
      _currentFrame++;
      // Just reached the last frame on a non-looping animation
      if (!_loop && _currentFrame >= _totalFrames - 1) {
        onFrame?.call(_currentFrame);
        _complete();
        return false;
      }
    }
    onFrame?.call(_currentFrame);
    return true;
  }

  bool _advanceReverse() {
    if (_currentFrame <= 0) {
      // At first frame - wrap or stop
      if (_loop) {
        _currentFrame = _totalFrames - 1;
      } else {
        _complete();
        return false;
      }
    } else {
      _currentFrame--;
      // Just reached the first frame on a non-looping reverse animation
      if (!_loop && _currentFrame <= 0) {
        onFrame?.call(_currentFrame);
        _complete();
        return false;
      }
    }
    onFrame?.call(_currentFrame);
    return true;
  }

  bool _advancePingPong() {
    if (_isForward) {
      _currentFrame++;
      if (_currentFrame >= _totalFrames) {
        _isForward = false;
        _currentFrame = _totalFrames - 2;
        if (_currentFrame < 0) _currentFrame = 0;
      }
    } else {
      _currentFrame--;
      if (_currentFrame < 0) {
        if (_loop) {
          _isForward = true;
          _currentFrame = 1;
          if (_currentFrame >= _totalFrames) _currentFrame = 0;
        } else {
          _currentFrame = 0;
          _complete();
          return false;
        }
      }
    }
    onFrame?.call(_currentFrame);
    return true;
  }

  void _complete() {
    _isPlaying = false;
    if (_ticker?.isActive ?? false) {
      _ticker!.stop();
    }
    onComplete?.call();
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    if (_ticker != null) {
      if (_ticker!.isActive) {
        _ticker!.stop();
      }
      _ticker!.dispose();
      _ticker = null;
    }
    super.dispose();
  }
}
