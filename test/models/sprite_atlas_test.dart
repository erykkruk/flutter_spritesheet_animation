import 'dart:convert';
import 'dart:ui';

import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpriteAtlas', () {
    group('TexturePacker hash format', () {
      test('parses frames correctly', () {
        final json = jsonEncode({
          'frames': {
            'sprite_0.png': {
              'frame': {'x': 0, 'y': 0, 'w': 64, 'h': 64},
              'rotated': false,
              'trimmed': false,
              'spriteSourceSize': {'x': 0, 'y': 0, 'w': 64, 'h': 64},
              'sourceSize': {'w': 64, 'h': 64},
            },
            'sprite_1.png': {
              'frame': {'x': 64, 'y': 0, 'w': 64, 'h': 64},
              'rotated': false,
              'trimmed': false,
              'spriteSourceSize': {'x': 0, 'y': 0, 'w': 64, 'h': 64},
              'sourceSize': {'w': 64, 'h': 64},
            },
          },
          'meta': {
            'size': {'w': 128, 'h': 64},
          },
        });

        final atlas = SpriteAtlas.fromJson(json);

        expect(atlas.frames.length, 2);
        expect(atlas.frames[0].rect.left, 0);
        expect(atlas.frames[1].rect.left, 64);
        expect(atlas.imageWidth, 128);
        expect(atlas.imageHeight, 64);
      });

      test('creates default animation when no frameTags', () {
        final json = jsonEncode({
          'frames': {
            'frame_0.png': {
              'frame': {'x': 0, 'y': 0, 'w': 32, 'h': 32},
            },
            'frame_1.png': {
              'frame': {'x': 32, 'y': 0, 'w': 32, 'h': 32},
            },
          },
        });

        final atlas = SpriteAtlas.fromJson(json);

        expect(atlas.animations.containsKey('default'), true);
        expect(atlas.animations['default']!.frameCount, 2);
      });
    });

    group('Aseprite / array format', () {
      test('parses array frames', () {
        final json = jsonEncode({
          'frames': [
            {
              'filename': 'char_0.png',
              'frame': {'x': 0, 'y': 0, 'w': 48, 'h': 48},
              'duration': 100,
            },
            {
              'filename': 'char_1.png',
              'frame': {'x': 48, 'y': 0, 'w': 48, 'h': 48},
              'duration': 100,
            },
            {
              'filename': 'char_2.png',
              'frame': {'x': 96, 'y': 0, 'w': 48, 'h': 48},
              'duration': 200,
            },
          ],
          'meta': {
            'size': {'w': 144, 'h': 48},
          },
        });

        final atlas = SpriteAtlas.fromJson(json);

        expect(atlas.frames.length, 3);
        expect(atlas.frames[0].duration, 100);
        expect(atlas.frames[2].duration, 200);
      });

      test('parses frameTags into named animations', () {
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
            'size': {'w': 160, 'h': 32},
            'frameTags': [
              {'name': 'idle', 'from': 0, 'to': 1},
              {'name': 'walk', 'from': 2, 'to': 4},
            ],
          },
        });

        final atlas = SpriteAtlas.fromJson(json);

        expect(atlas.animationNames, containsAll(['idle', 'walk']));
        expect(atlas.getAnimation('idle').frameCount, 2);
        expect(atlas.getAnimation('walk').frameCount, 3);
      });
    });

    group('trimmed frames', () {
      test('parses trimmed frame data', () {
        final json = jsonEncode({
          'frames': {
            'trimmed.png': {
              'frame': {'x': 10, 'y': 20, 'w': 30, 'h': 40},
              'rotated': false,
              'trimmed': true,
              'spriteSourceSize': {'x': 5, 'y': 10, 'w': 30, 'h': 40},
              'sourceSize': {'w': 64, 'h': 64},
            },
          },
        });

        final atlas = SpriteAtlas.fromJson(json);
        final frame = atlas.frames.first;

        expect(frame.trimmed, true);
        expect(frame.sourceSize, const Size(64, 64));
        expect(frame.offset.dx, 5);
        expect(frame.offset.dy, 10);
      });
    });

    group('error handling', () {
      test('throws on invalid JSON', () {
        expect(() => SpriteAtlas.fromJson('not json'), throwsFormatException);
      });

      test('throws on missing frames key', () {
        expect(
          () => SpriteAtlas.fromJson('{"meta": {}}'),
          throwsFormatException,
        );
      });

      test('throws on invalid frames type', () {
        expect(
          () => SpriteAtlas.fromJson('{"frames": "bad"}'),
          throwsFormatException,
        );
      });

      test('getAnimation throws on unknown name', () {
        final json = jsonEncode({
          'frames': {
            'f.png': {
              'frame': {'x': 0, 'y': 0, 'w': 32, 'h': 32},
            },
          },
        });

        final atlas = SpriteAtlas.fromJson(json);
        expect(() => atlas.getAnimation('nonexistent'), throwsArgumentError);
      });
    });

    test('toString', () {
      final json = jsonEncode({
        'frames': {
          'f.png': {
            'frame': {'x': 0, 'y': 0, 'w': 32, 'h': 32},
          },
        },
      });

      final atlas = SpriteAtlas.fromJson(json);
      expect(atlas.toString(), contains('SpriteAtlas'));
      expect(atlas.toString(), contains('1'));
    });
  });
}
