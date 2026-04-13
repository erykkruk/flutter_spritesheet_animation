import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpriteAnimation', () {
    group('grid constructor', () {
      test('isGrid returns true', () {
        const widget = SpriteAnimation.grid(
          image: AssetImage('test.png'),
          columns: 4,
          rows: 2,
        );

        expect(widget.isGrid, true);
        expect(widget.columns, 4);
        expect(widget.rows, 2);
        expect(widget.atlas, isNull);
      });

      test('frameCount defaults to columns * rows conceptually', () {
        const widget = SpriteAnimation.grid(
          image: AssetImage('test.png'),
          columns: 4,
          rows: 2,
        );

        expect(widget.frameCount, isNull); // Widget computes internally
      });

      test('accepts custom frameCount', () {
        const widget = SpriteAnimation.grid(
          image: AssetImage('test.png'),
          columns: 4,
          rows: 2,
          frameCount: 6,
        );

        expect(widget.frameCount, 6);
      });
    });

    group('atlas constructor', () {
      test('isGrid returns false', () {
        final atlas = SpriteAtlas.fromJson(
          jsonEncode({
            'frames': {
              'f.png': {
                'frame': {'x': 0, 'y': 0, 'w': 32, 'h': 32},
              },
            },
          }),
        );

        final widget = SpriteAnimation.atlas(
          image: const AssetImage('test.png'),
          atlas: atlas,
        );

        expect(widget.isGrid, false);
        expect(widget.atlas, isNotNull);
        expect(widget.columns, isNull);
        expect(widget.rows, isNull);
      });
    });

    group('default values', () {
      test('has sensible defaults', () {
        const widget = SpriteAnimation.grid(
          image: AssetImage('test.png'),
          columns: 4,
          rows: 2,
        );

        expect(widget.fps, 12);
        expect(widget.autoPlay, true);
        expect(widget.loop, true);
        expect(widget.mode, PlayMode.forward);
        expect(widget.blendMode, BlendMode.srcOver);
        expect(widget.fit, BoxFit.contain);
        expect(widget.controller, isNull);
      });
    });

    group('widget rendering', () {
      testWidgets('renders empty SizedBox while image loads', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SpriteAnimation.grid(
              image: AssetImage('nonexistent.png'),
              columns: 4,
              rows: 2,
              width: 200,
              height: 100,
            ),
          ),
        );

        // Should render a SizedBox placeholder while image loads
        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('accepts external controller', (tester) async {
        final controller = SpriteAnimationController(autoPlay: false);

        await tester.pumpWidget(
          MaterialApp(
            home: SpriteAnimation.grid(
              image: const AssetImage('test.png'),
              columns: 4,
              rows: 2,
              controller: controller,
            ),
          ),
        );

        expect(controller.totalFrames, 8);
        expect(controller.isPlaying, false);

        controller.dispose();
      });
    });
  });
}
