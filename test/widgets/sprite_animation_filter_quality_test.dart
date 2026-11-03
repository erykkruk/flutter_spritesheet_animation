import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';
import 'package:flutter_test/flutter_test.dart';

const int _kSheetWidth = 2;
const int _kSheetHeight = 1;
const double _kRenderWidth = 64;
const double _kRenderHeight = 32;
const int _kBytesPerPixel = 4;
const int _kCrispColorCount = 2;

const Color _kLeftColor = Color(0xFFFF0000);
const Color _kRightColor = Color(0xFF0000FF);
const String _kAnimationName = 'only';

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

/// Two hard-edged pixels: any color other than these two after upscaling can
/// only come from filtering.
Future<ui.Image> _createTwoPixelSheet() {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = _kLeftColor)
    ..drawRect(const Rect.fromLTWH(1, 0, 1, 1), Paint()..color = _kRightColor);
  return recorder.endRecording().toImage(_kSheetWidth, _kSheetHeight);
}

void main() {
  const boundaryKey = Key('boundary');
  // Kept across rebuilds: a new provider would reload the image and repaint
  // on its own, hiding a missing repaint from the settings under test.
  late _ReadyImage image;
  late SpriteAtlas atlas;

  setUpAll(() async {
    image = _ReadyImage(await _createTwoPixelSheet());
    final frames = [
      SpriteFrame(
        rect: Rect.fromLTWH(
          0,
          0,
          _kSheetWidth.toDouble(),
          _kSheetHeight.toDouble(),
        ),
      ),
    ];
    atlas = SpriteAtlas(
      frames: frames,
      animations: {
        _kAnimationName: SpriteAnimationData(
          name: _kAnimationName,
          frames: frames,
        ),
      },
    );
  });

  Widget harness(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: RepaintBoundary(key: boundaryKey, child: child),
      ),
    );
  }

  Widget grid({
    FilterQuality? filterQuality,
    BlendMode blendMode = BlendMode.srcOver,
  }) {
    return harness(
      filterQuality == null
          ? SpriteAnimation.grid(
              image: image,
              columns: 1,
              rows: 1,
              autoPlay: false,
              blendMode: blendMode,
              fit: BoxFit.fill,
              width: _kRenderWidth,
              height: _kRenderHeight,
            )
          : SpriteAnimation.grid(
              image: image,
              columns: 1,
              rows: 1,
              autoPlay: false,
              blendMode: blendMode,
              filterQuality: filterQuality,
              fit: BoxFit.fill,
              width: _kRenderWidth,
              height: _kRenderHeight,
            ),
    );
  }

  Future<Set<int>> renderedColors(WidgetTester tester) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundaryKey),
    );
    final bytes = await tester.runAsync(() async {
      final rendered = await boundary.toImage();
      final data = await rendered.toByteData();
      rendered.dispose();
      return data!;
    });
    final colors = <int>{};
    final view = bytes!.buffer.asUint8List();
    final rgba = ByteData.sublistView(view);
    for (var i = 0; i < view.length; i += _kBytesPerPixel) {
      colors.add(rgba.getUint32(i));
    }
    return colors;
  }

  testWidgets('defaults to FilterQuality.low', (tester) async {
    await tester.pumpWidget(grid());

    final widget = tester.widget<SpriteAnimation>(find.byType(SpriteAnimation));
    expect(widget.filterQuality, FilterQuality.low);
  });

  testWidgets('default smooths the frame when scaling up', (tester) async {
    await tester.pumpWidget(grid());
    await tester.pump();

    expect(
      (await renderedColors(tester)).length,
      greaterThan(_kCrispColorCount),
    );
  });

  testWidgets('FilterQuality.none keeps hard pixel edges on a grid', (
    tester,
  ) async {
    await tester.pumpWidget(grid(filterQuality: FilterQuality.none));
    await tester.pump();

    expect((await renderedColors(tester)).length, _kCrispColorCount);
  });

  testWidgets('FilterQuality.none keeps hard pixel edges on an atlas', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        SpriteAnimation.atlas(
          image: image,
          atlas: atlas,
          autoPlay: false,
          filterQuality: FilterQuality.none,
          fit: BoxFit.fill,
          width: _kRenderWidth,
          height: _kRenderHeight,
        ),
      ),
    );
    await tester.pump();

    expect((await renderedColors(tester)).length, _kCrispColorCount);
  });

  testWidgets('changing filterQuality repaints a paused animation', (
    tester,
  ) async {
    await tester.pumpWidget(grid(filterQuality: FilterQuality.low));
    await tester.pump();
    expect(
      (await renderedColors(tester)).length,
      greaterThan(_kCrispColorCount),
    );

    await tester.pumpWidget(grid(filterQuality: FilterQuality.none));

    expect((await renderedColors(tester)).length, _kCrispColorCount);
  });

  testWidgets('changing blendMode repaints a paused animation', (tester) async {
    await tester.pumpWidget(grid(filterQuality: FilterQuality.none));
    await tester.pump();
    expect((await renderedColors(tester)).length, _kCrispColorCount);

    await tester.pumpWidget(
      grid(filterQuality: FilterQuality.none, blendMode: BlendMode.clear),
    );

    expect(await renderedColors(tester), {0});
  });
}
