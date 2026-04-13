import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal TickerProvider for tests (same pattern as Flutter's TestVSync).
class _TestVSync implements TickerProvider {
  const _TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  group('SpriteAnimationController', () {
    late SpriteAnimationController controller;

    setUp(() {
      controller = SpriteAnimationController(autoPlay: false);
    });

    tearDown(() {
      controller.dispose();
    });

    group('initial state', () {
      test('has correct defaults', () {
        expect(controller.fps, 12);
        expect(controller.mode, PlayMode.forward);
        expect(controller.loop, true);
        expect(controller.isPlaying, false);
        expect(controller.currentFrame, 0);
        expect(controller.totalFrames, 0);
        expect(controller.animationName, isNull);
      });

      test('accepts custom initial values', () {
        final custom = SpriteAnimationController(
          fps: 24,
          mode: PlayMode.pingPong,
          loop: false,
          autoPlay: false,
        );

        expect(custom.fps, 24);
        expect(custom.mode, PlayMode.pingPong);
        expect(custom.loop, false);

        custom.dispose();
      });
    });

    group('configuration', () {
      test('fps setter validates positive value', () {
        controller.fps = 30;
        expect(controller.fps, 30);

        expect(() => controller.fps = 0, throwsArgumentError);
        expect(() => controller.fps = -1, throwsArgumentError);
      });

      test('fps setter notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.fps = 24;
        expect(notified, true);
      });

      test('mode setter notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.mode = PlayMode.reverse;
        expect(notified, true);
        expect(controller.mode, PlayMode.reverse);
      });

      test('loop setter notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.loop = false;
        expect(notified, true);
        expect(controller.loop, false);
      });

      test('setters do not notify if value unchanged', () {
        var count = 0;
        controller.addListener(() => count++);

        controller.fps = 12;
        controller.mode = PlayMode.forward;
        controller.loop = true;

        expect(count, 0);
      });
    });

    group('setupGrid', () {
      test('sets total frames', () {
        controller.setupGrid(totalFrames: 10);
        expect(controller.totalFrames, 10);
        expect(controller.animationName, isNull);
      });

      test('clamps current frame to valid range', () {
        controller.setupGrid(totalFrames: 10);
        controller.goToFrame(9);

        controller.setupGrid(totalFrames: 5);
        expect(controller.currentFrame, 4);
      });
    });

    group('setupAtlas', () {
      late SpriteAtlas atlas;

      setUp(() {
        final json = jsonEncode({
          'frames': [
            {
              'filename': 'idle_0.png',
              'frame': {'x': 0, 'y': 0, 'w': 32, 'h': 32},
            },
            {
              'filename': 'idle_1.png',
              'frame': {'x': 32, 'y': 0, 'w': 32, 'h': 32},
            },
            {
              'filename': 'walk_0.png',
              'frame': {'x': 64, 'y': 0, 'w': 32, 'h': 32},
            },
            {
              'filename': 'walk_1.png',
              'frame': {'x': 96, 'y': 0, 'w': 32, 'h': 32},
            },
            {
              'filename': 'walk_2.png',
              'frame': {'x': 128, 'y': 0, 'w': 32, 'h': 32},
            },
          ],
          'meta': {
            'frameTags': [
              {'name': 'idle', 'from': 0, 'to': 1},
              {'name': 'walk', 'from': 2, 'to': 4},
            ],
          },
        });
        atlas = SpriteAtlas.fromJson(json);
      });

      test('sets up first animation by default', () {
        controller.setupAtlas(atlas: atlas);

        expect(controller.animationName, 'idle');
        expect(controller.totalFrames, 2);
        expect(controller.currentFrame, 0);
      });

      test('sets up named animation', () {
        controller.setupAtlas(atlas: atlas, animationName: 'walk');

        expect(controller.animationName, 'walk');
        expect(controller.totalFrames, 3);
      });

      test('setAnimation switches animation', () {
        controller.setupAtlas(atlas: atlas, animationName: 'idle');
        controller.goToFrame(1);

        controller.setAnimation('walk', atlas: atlas);

        expect(controller.animationName, 'walk');
        expect(controller.totalFrames, 3);
        expect(controller.currentFrame, 0);
      });
    });

    group('goToFrame', () {
      setUp(() {
        controller.setupGrid(totalFrames: 10);
      });

      test('jumps to specific frame', () {
        controller.goToFrame(5);
        expect(controller.currentFrame, 5);
      });

      test('clamps to valid range', () {
        controller.goToFrame(-1);
        expect(controller.currentFrame, 0);

        controller.goToFrame(100);
        expect(controller.currentFrame, 9);
      });

      test('notifies listeners', () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.goToFrame(3);
        expect(notified, true);
      });

      test('does not notify if frame unchanged', () {
        controller.goToFrame(0);
        var count = 0;
        controller.addListener(() => count++);

        controller.goToFrame(0);
        expect(count, 0);
      });

      test('calls onFrame callback', () {
        int? reportedFrame;
        controller.onFrame = (frame) => reportedFrame = frame;

        controller.goToFrame(7);
        expect(reportedFrame, 7);
      });
    });

    group('play/pause/stop', () {
      test('play does nothing with zero frames', () {
        controller.play();
        expect(controller.isPlaying, false);
      });

      test('stop resets to frame 0', () {
        controller.setupGrid(totalFrames: 10);
        controller.goToFrame(5);
        controller.stop();

        expect(controller.currentFrame, 0);
        expect(controller.isPlaying, false);
      });
    });

    group('playback with ticker', () {
      // Use 5 fps = 200ms per frame.
      const testFps = 5.0;

      testWidgets('plays forward through frames', (tester) async {
        controller = SpriteAnimationController(fps: testFps, autoPlay: false);
        controller.attach(const _TestVSync());
        controller.setupGrid(totalFrames: 5);
        controller.play();

        await tester.pump();

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 1);

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 2);

        controller.stop();
      });

      testWidgets('loops when loop is true', (tester) async {
        controller = SpriteAnimationController(
          fps: testFps,
          loop: true,
          autoPlay: false,
        );
        controller.attach(const _TestVSync());
        controller.setupGrid(totalFrames: 3);
        controller.play();

        await tester.pump();

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 1);

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 2);

        // Should loop back to 0
        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 0);

        controller.stop();
      });

      testWidgets('stops when loop is false', (tester) async {
        var completed = false;
        controller = SpriteAnimationController(
          fps: testFps,
          loop: false,
          autoPlay: false,
        );
        controller.onComplete = () => completed = true;
        controller.attach(const _TestVSync());
        controller.setupGrid(totalFrames: 3);
        controller.play();

        await tester.pump();

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 1);

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 2);
        expect(controller.isPlaying, false);
        expect(completed, true);
      });

      testWidgets('reverse mode plays backwards', (tester) async {
        controller = SpriteAnimationController(
          fps: testFps,
          mode: PlayMode.reverse,
          loop: true,
          autoPlay: false,
        );
        controller.attach(const _TestVSync());
        controller.setupGrid(totalFrames: 3);
        controller.goToFrame(2);
        controller.play();

        await tester.pump();

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 1);

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 0);

        // Should wrap to last frame (looping)
        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 2);

        controller.stop();
      });

      testWidgets('pause stops advancing', (tester) async {
        controller = SpriteAnimationController(fps: testFps, autoPlay: false);
        controller.attach(const _TestVSync());
        controller.setupGrid(totalFrames: 10);
        controller.play();

        await tester.pump();

        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.currentFrame, 1);

        controller.pause();

        await tester.pump(const Duration(milliseconds: 500));
        expect(controller.currentFrame, 1);
      });
    });
  });
}
