import 'dart:ui';

import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpriteFrame', () {
    test('creates with required parameters', () {
      const frame = SpriteFrame(rect: Rect.fromLTWH(0, 0, 64, 64));

      expect(frame.rect, const Rect.fromLTWH(0, 0, 64, 64));
      expect(frame.duration, isNull);
      expect(frame.sourceSize, isNull);
      expect(frame.offset, Offset.zero);
      expect(frame.rotated, false);
      expect(frame.trimmed, false);
    });

    test('creates with all parameters', () {
      const frame = SpriteFrame(
        rect: Rect.fromLTWH(10, 20, 32, 48),
        duration: 100,
        sourceSize: Size(64, 64),
        offset: Offset(5, 10),
        rotated: true,
        trimmed: true,
      );

      expect(frame.rect, const Rect.fromLTWH(10, 20, 32, 48));
      expect(frame.duration, 100);
      expect(frame.sourceSize, const Size(64, 64));
      expect(frame.offset, const Offset(5, 10));
      expect(frame.rotated, true);
      expect(frame.trimmed, true);
    });

    test('width and height account for rotation', () {
      const frame = SpriteFrame(
        rect: Rect.fromLTWH(0, 0, 32, 64),
        rotated: false,
      );
      expect(frame.width, 32);
      expect(frame.height, 64);

      const rotatedFrame = SpriteFrame(
        rect: Rect.fromLTWH(0, 0, 32, 64),
        rotated: true,
      );
      expect(rotatedFrame.width, 64);
      expect(rotatedFrame.height, 32);
    });

    test('equality', () {
      const a = SpriteFrame(rect: Rect.fromLTWH(0, 0, 64, 64));
      const b = SpriteFrame(rect: Rect.fromLTWH(0, 0, 64, 64));
      const c = SpriteFrame(rect: Rect.fromLTWH(0, 0, 32, 32));

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString', () {
      const frame = SpriteFrame(
        rect: Rect.fromLTWH(0, 0, 64, 64),
        duration: 100,
      );

      expect(frame.toString(), contains('SpriteFrame'));
      expect(frame.toString(), contains('64'));
      expect(frame.toString(), contains('100'));
    });
  });
}
