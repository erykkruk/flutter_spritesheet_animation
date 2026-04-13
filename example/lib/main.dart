import 'package:flutter/material.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spritesheet Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const BackpackDemo(),
    );
  }
}

class BackpackDemo extends StatefulWidget {
  const BackpackDemo({super.key});

  @override
  State<BackpackDemo> createState() => _BackpackDemoState();
}

class _BackpackDemoState extends State<BackpackDemo> {
  final _controller = SpriteAnimationController(
    fps: 30,
    autoPlay: true,
    loop: true,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backpack Spritesheet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpriteAnimation.grid(
              image: const AssetImage('assets/backpack.png'),
              columns: 8,
              rows: 8,
              frameCount: 64,
              controller: _controller,
              width: 256,
              height: 256,
            ),
            const SizedBox(height: 24),
            Text(
              'Frame: ${_controller.currentFrame} / ${_controller.totalFrames}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: _controller.stop,
                  tooltip: 'Stop',
                ),
                IconButton(
                  icon: Icon(
                    _controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    if (_controller.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  },
                  tooltip: _controller.isPlaying ? 'Pause' : 'Play',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () =>
                      _controller.goToFrame(_controller.currentFrame - 1),
                  tooltip: 'Previous frame',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () =>
                      _controller.goToFrame(_controller.currentFrame + 1),
                  tooltip: 'Next frame',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Speed control
            Text(
              'Speed: ${_controller.fps.round()} FPS',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _controller.fps > 1
                      ? () => _controller.fps =
                          (_controller.fps - 5).clamp(1, 120)
                      : null,
                  tooltip: 'Slower',
                ),
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: _controller.fps,
                    min: 1,
                    max: 120,
                    divisions: 119,
                    label: '${_controller.fps.round()} FPS',
                    onChanged: (v) => _controller.fps = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _controller.fps < 120
                      ? () => _controller.fps =
                          (_controller.fps + 5).clamp(1, 120)
                      : null,
                  tooltip: 'Faster',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Play mode
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final mode in PlayMode.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(mode.name),
                      selected: _controller.mode == mode,
                      onSelected: (_) => _controller.mode = mode,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    _controller.dispose();
    super.dispose();
  }
}
