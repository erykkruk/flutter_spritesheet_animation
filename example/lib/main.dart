import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spritesheet Animation',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spritesheet Animation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Grid Mode'),
          const SizedBox(height: 8),
          const GridExample(),
          const SizedBox(height: 32),
          const _SectionHeader(title: 'Atlas Mode'),
          const SizedBox(height: 8),
          const AtlasExample(),
          const SizedBox(height: 32),
          const _SectionHeader(title: 'Controller'),
          const SizedBox(height: 8),
          const ControllerExample(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Grid Example
// -----------------------------------------------------------------------------

class GridExample extends StatelessWidget {
  const GridExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grid-based spritesheet with 8 columns, 4 rows.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Center(
              child: SpriteAnimation.grid(
                image: AssetImage('assets/explosion.png'),
                columns: 8,
                rows: 4,
                fps: 24,
                width: 128,
                height: 128,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Atlas Example
// -----------------------------------------------------------------------------

class AtlasExample extends StatefulWidget {
  const AtlasExample({super.key});

  @override
  State<AtlasExample> createState() => _AtlasExampleState();
}

class _AtlasExampleState extends State<AtlasExample> {
  SpriteAtlas? _atlas;
  String _currentAnimation = 'idle';

  @override
  void initState() {
    super.initState();
    _loadAtlas();
  }

  Future<void> _loadAtlas() async {
    // In a real app, load from assets:
    // final atlas = await SpriteAtlas.fromAsset('assets/character.json');
    final json = jsonEncode({
      'frames': [
        {
          'filename': 'idle_0.png',
          'frame': {'x': 0, 'y': 0, 'w': 64, 'h': 64},
          'duration': 100,
        },
        {
          'filename': 'idle_1.png',
          'frame': {'x': 64, 'y': 0, 'w': 64, 'h': 64},
          'duration': 100,
        },
        {
          'filename': 'walk_0.png',
          'frame': {'x': 0, 'y': 64, 'w': 64, 'h': 64},
          'duration': 80,
        },
        {
          'filename': 'walk_1.png',
          'frame': {'x': 64, 'y': 64, 'w': 64, 'h': 64},
          'duration': 80,
        },
        {
          'filename': 'walk_2.png',
          'frame': {'x': 128, 'y': 64, 'w': 64, 'h': 64},
          'duration': 80,
        },
      ],
      'meta': {
        'frameTags': [
          {'name': 'idle', 'from': 0, 'to': 1},
          {'name': 'walk', 'from': 2, 'to': 4},
        ],
      },
    });
    setState(() {
      _atlas = SpriteAtlas.fromJson(json);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_atlas == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atlas with named animations: ${_atlas!.animationNames.join(", ")}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Center(
              child: SpriteAnimation.atlas(
                image: const AssetImage('assets/character.png'),
                atlas: _atlas!,
                animation: _currentAnimation,
                width: 128,
                height: 128,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final name in _atlas!.animationNames)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(name),
                      selected: _currentAnimation == name,
                      onSelected: (_) {
                        setState(() => _currentAnimation = name);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Controller Example
// -----------------------------------------------------------------------------

class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample> {
  final _controller = SpriteAnimationController(fps: 12, autoPlay: false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'External controller with playback controls.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Center(
              child: SpriteAnimation.grid(
                image: const AssetImage('assets/explosion.png'),
                columns: 8,
                rows: 4,
                controller: _controller,
                width: 128,
                height: 128,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Frame: ${_controller.currentFrame} / ${_controller.totalFrames}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: _controller.stop,
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
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () =>
                      _controller.goToFrame(_controller.currentFrame - 1),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () =>
                      _controller.goToFrame(_controller.currentFrame + 1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Mode: ', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                for (final mode in PlayMode.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(mode.name),
                      selected: _controller.mode == mode,
                      onSelected: (_) {
                        _controller.mode = mode;
                      },
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
    _controller.dispose();
    super.dispose();
  }
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}
