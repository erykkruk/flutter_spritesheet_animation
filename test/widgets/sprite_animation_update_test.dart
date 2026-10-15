import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:flutter_test/flutter_test.dart';

const int _kSheetWidth = 64;
const int _kSheetHeight = 32;
const double _kFps = 10;
const Duration _kFrameStep = Duration(milliseconds: 110);

/// Hands out an already decoded image synchronously, so the widget has its
/// spritesheet on the first pump and paints straight away.
class _ReadyImage extends ImageProvider<_ReadyImage> {
  const _ReadyImage(this.image);

  final ui.Image image;

  @override
  Future<_ReadyImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_ReadyImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _ReadyImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    SynchronousFuture<ImageInfo>(ImageInfo(image: image.clone())),
  );
}

void main() {
  late ui.Image sheet;

  setUpAll(() async {
    sheet = await createTestImage(width: _kSheetWidth, height: _kSheetHeight);
  });

  Widget grid({
    required int columns,
    required int rows,
    int? frameCount,
    SpriteAnimationController? controller,
    ValueChanged<int>? onFrame,
  }) {
    return MaterialApp(
      home: SpriteAnimation.grid(
        image: _ReadyImage(sheet),
        columns: columns,
        rows: rows,
        frameCount: frameCount,
        fps: _kFps,
        controller: controller,
        onFrame: onFrame,
        width: 100,
        height: 100,
      ),
    );
  }

  RenderObject spritePaint(WidgetTester tester) => tester.renderObject(
    find.descendant(
      of: find.byType(SpriteAnimation),
      matching: find.byType(CustomPaint),
    ),
  );

  group('grid config changes', () {
    testWidgets('keep painting with the new frame size', (tester) async {
      // Arrange
      final controller = SpriteAnimationController(autoPlay: false);
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, controller: controller),
      );
      expect(
        spritePaint(tester),
        paints..drawImageRect(source: const Rect.fromLTWH(0, 0, 16, 16)),
      );

      // Act
      await tester.pumpWidget(
        grid(columns: 2, rows: 1, controller: controller),
      );

      // Assert
      expect(
        spritePaint(tester),
        paints..drawImageRect(source: const Rect.fromLTWH(0, 0, 32, 32)),
      );
      controller.dispose();
    });

    testWidgets('update the controller frame count', (tester) async {
      // Arrange
      final controller = SpriteAnimationController(autoPlay: false);
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, controller: controller),
      );
      controller.goToFrame(7);

      // Act
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, frameCount: 3, controller: controller),
      );

      // Assert
      expect(controller.totalFrames, 3);
      expect(controller.currentFrame, 2);
      controller.dispose();
    });

    testWidgets('do not resume a paused animation', (tester) async {
      // Arrange
      final controller = SpriteAnimationController();
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, controller: controller),
      );
      controller.pause();

      // Act
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, frameCount: 6, controller: controller),
      );

      // Assert
      expect(controller.totalFrames, 6);
      expect(controller.isPlaying, false);
      controller.dispose();
    });
  });

  group('callbacks', () {
    testWidgets('keep those set on an external controller', (tester) async {
      // Arrange
      void onComplete() {}
      void onFrame(int _) {}
      final controller = SpriteAnimationController(autoPlay: false)
        ..onComplete = onComplete
        ..onFrame = onFrame;

      // Act
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, controller: controller),
      );

      // Assert
      expect(controller.onComplete, same(onComplete));
      expect(controller.onFrame, same(onFrame));
      controller.dispose();
    });

    testWidgets('widget callbacks replace the controller ones', (tester) async {
      // Arrange
      void controllerOnFrame(int _) {}
      void widgetOnFrame(int _) {}
      final controller = SpriteAnimationController(autoPlay: false)
        ..onFrame = controllerOnFrame;

      // Act
      await tester.pumpWidget(
        grid(
          columns: 4,
          rows: 2,
          controller: controller,
          onFrame: widgetOnFrame,
        ),
      );

      // Assert
      expect(controller.onFrame, same(widgetOnFrame));
      controller.dispose();
    });

    testWidgets('follow the latest widget build', (tester) async {
      // Arrange
      final firstFrames = <int>[];
      final latestFrames = <int>[];
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, onFrame: firstFrames.add),
      );
      await tester.pumpWidget(
        grid(columns: 4, rows: 2, onFrame: latestFrames.add),
      );

      // Act
      await tester.pump(_kFrameStep);
      await tester.pump(_kFrameStep);

      // Assert
      expect(firstFrames, isEmpty);
      expect(latestFrames, [1, 2]);
    });
  });
}
