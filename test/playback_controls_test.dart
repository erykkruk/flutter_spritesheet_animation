import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('speed', () {
    test('defaults to real time', () {
      expect(SpriteAnimationController().speed, 1);
    });

    test('is set from the constructor', () {
      expect(SpriteAnimationController(speed: 2.5).speed, 2.5);
    });

    test('rejects a non-positive value in the constructor', () {
      // Zero would stall the animation clock instead of pausing it, which
      // is what pause() is for.
      expect(() => SpriteAnimationController(speed: 0), throwsArgumentError);
      expect(() => SpriteAnimationController(speed: -1), throwsArgumentError);
    });

    test('rejects a non-positive value from the setter', () {
      final controller = SpriteAnimationController();

      expect(() => controller.speed = 0, throwsArgumentError);
      expect(() => controller.speed = -0.5, throwsArgumentError);
      expect(controller.speed, 1, reason: 'a rejected value must not stick');
    });

    test('notifies listeners when it changes', () {
      final controller = SpriteAnimationController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.speed = 2;

      expect(controller.speed, 2);
      expect(notifications, 1);
    });

    test('setting the same value notifies nobody', () {
      final controller = SpriteAnimationController(speed: 2);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.speed = 2;

      expect(notifications, 0);
    });
  });

  group('repeatCount', () {
    test('defaults to unlimited', () {
      expect(SpriteAnimationController().repeatCount, isNull);
    });

    test('is set from the constructor', () {
      expect(SpriteAnimationController(repeatCount: 3).repeatCount, 3);
    });

    test('rejects a non-positive value in the constructor', () {
      expect(
        () => SpriteAnimationController(repeatCount: 0),
        throwsArgumentError,
      );
      expect(
        () => SpriteAnimationController(repeatCount: -2),
        throwsArgumentError,
      );
    });

    test('rejects a non-positive value from the setter', () {
      final controller = SpriteAnimationController(repeatCount: 2);

      expect(() => controller.repeatCount = 0, throwsArgumentError);
      expect(controller.repeatCount, 2);
    });

    test('null means unlimited and is accepted by the setter', () {
      final controller = SpriteAnimationController(repeatCount: 3);

      controller.repeatCount = null;

      expect(controller.repeatCount, isNull);
    });

    test('changing it resets the completed cycle count', () {
      // The new limit should apply from now, not count cycles that already
      // ran under the old one.
      final controller = SpriteAnimationController(repeatCount: 5);
      controller.setupGrid(totalFrames: 4);

      controller.repeatCount = 2;

      expect(controller.completedCycles, 0);
    });

    test('notifies listeners when it changes', () {
      final controller = SpriteAnimationController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.repeatCount = 4;

      expect(notifications, 1);
    });
  });

  group('completedCycles', () {
    test('starts at zero', () {
      expect(SpriteAnimationController().completedCycles, 0);
    });

    test('is reset by stop()', () {
      final controller = SpriteAnimationController(autoPlay: false);
      controller.setupGrid(totalFrames: 3);

      controller.stop();

      expect(controller.completedCycles, 0);
      expect(controller.currentFrame, 0);
    });
  });

  group('existing behaviour is untouched', () {
    test('fps still validates on construction', () {
      expect(() => SpriteAnimationController(fps: 0), throwsArgumentError);
    });

    test('defaults still loop forward and autoplay', () {
      final controller = SpriteAnimationController();

      expect(controller.loop, isTrue);
      expect(controller.mode, PlayMode.forward);
      expect(controller.autoPlay, isTrue);
    });

    test('goToFrame still clamps into range', () {
      final controller = SpriteAnimationController(autoPlay: false);
      controller.setupGrid(totalFrames: 5);

      controller.goToFrame(99);
      expect(controller.currentFrame, 4);

      controller.goToFrame(-3);
      expect(controller.currentFrame, 0);
    });

    test('onCycle starts unset', () {
      expect(SpriteAnimationController().onCycle, isNull);
    });
  });
}
