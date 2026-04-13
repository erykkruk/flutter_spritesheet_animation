# flutter_spritesheet_animation

Lightweight spritesheet animation widget for Flutter. Supports grid-based and JSON atlas (TexturePacker, Aseprite) spritesheets with named animations, playback modes, and an external controller.

**Zero external dependencies** - uses only the Flutter SDK.

## Features

- Grid-based spritesheet animation (uniform frame grid)
- JSON atlas animation (TexturePacker hash/array, Aseprite)
- Named animations via `frameTags`
- Playback modes: forward, reverse, pingPong
- External controller for programmatic control
- Per-frame duration support from atlas data
- Pre-computed frame rects for optimal rendering
- Configurable FPS, looping, blend mode, box fit

## Installation

```yaml
dependencies:
  flutter_spritesheet_animation: ^1.0.0
```

## Usage

### Grid Mode

For spritesheets with frames arranged in a uniform grid:

```dart
SpriteAnimation.grid(
  image: AssetImage('assets/explosion.png'),
  columns: 8,
  rows: 4,
  frameCount: 30,  // optional, defaults to columns * rows
  fps: 24,
  width: 128,
  height: 128,
)
```

### Atlas Mode

For spritesheets defined by a JSON atlas (TexturePacker or Aseprite export):

```dart
// Load atlas from asset
final atlas = await SpriteAtlas.fromAsset('assets/character.json');

SpriteAnimation.atlas(
  image: AssetImage('assets/character.png'),
  atlas: atlas,
  animation: 'idle',  // named animation from frameTags
  width: 128,
  height: 128,
)
```

### Controller

Use `SpriteAnimationController` for programmatic playback control:

```dart
final controller = SpriteAnimationController(
  fps: 24,
  mode: PlayMode.pingPong,
  loop: true,
  autoPlay: false,
);

// In your widget tree
SpriteAnimation.grid(
  image: AssetImage('assets/explosion.png'),
  columns: 8,
  rows: 4,
  controller: controller,
)

// Control playback
controller.play();
controller.pause();
controller.stop();
controller.goToFrame(5);

// Change settings at runtime
controller.fps = 30;
controller.mode = PlayMode.reverse;
controller.loop = false;

// Switch named animations (atlas mode)
controller.setAnimation('walk', atlas: atlas);

// Read state
controller.isPlaying;    // bool
controller.currentFrame; // int
controller.totalFrames;  // int
controller.animationName; // String?

// Don't forget to dispose when using externally
controller.dispose();
```

### Callbacks

```dart
SpriteAnimation.grid(
  image: AssetImage('assets/explosion.png'),
  columns: 8,
  rows: 4,
  loop: false,
  onFrame: (frame) => print('Frame: $frame'),
  onComplete: () => print('Animation finished'),
)
```

### Atlas JSON Formats

**TexturePacker (hash)**:
```json
{
  "frames": {
    "idle_0.png": {
      "frame": { "x": 0, "y": 0, "w": 64, "h": 64 },
      "rotated": false,
      "trimmed": false,
      "spriteSourceSize": { "x": 0, "y": 0, "w": 64, "h": 64 },
      "sourceSize": { "w": 64, "h": 64 }
    }
  },
  "meta": {
    "size": { "w": 256, "h": 256 },
    "frameTags": [
      { "name": "idle", "from": 0, "to": 3 },
      { "name": "walk", "from": 4, "to": 9 }
    ]
  }
}
```

**Aseprite (array)**:
```json
{
  "frames": [
    {
      "filename": "idle_0.png",
      "frame": { "x": 0, "y": 0, "w": 64, "h": 64 },
      "duration": 100
    }
  ],
  "meta": {
    "frameTags": [
      { "name": "idle", "from": 0, "to": 3 }
    ]
  }
}
```

Both formats are auto-detected.

## Performance

Optimized for smooth 60fps animation rendering:

- **Pre-computed frame rects**: Grid source rectangles are calculated once at load time, not during paint
- **Reusable Paint object**: Single Paint instance reused across frames, avoiding per-frame allocations
- **Accumulator-based timing**: Frame advancement uses a time accumulator pattern for accurate frame pacing
- **Efficient shouldRepaint**: Only repaints when frame index, image, or blend mode actually changes
- **No external dependencies**: Zero overhead from third-party packages

## API Reference

### SpriteAnimation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `image` | `ImageProvider` | required | Spritesheet image |
| `columns` | `int` | - | Grid columns (grid mode) |
| `rows` | `int` | - | Grid rows (grid mode) |
| `frameCount` | `int?` | columns*rows | Total frames (grid mode) |
| `atlas` | `SpriteAtlas` | - | Atlas data (atlas mode) |
| `animation` | `String?` | first | Animation name (atlas mode) |
| `fps` | `double` | 12 | Frames per second |
| `autoPlay` | `bool` | true | Start automatically |
| `loop` | `bool` | true | Loop animation |
| `mode` | `PlayMode` | forward | Playback direction |
| `blendMode` | `BlendMode` | srcOver | Canvas blend mode |
| `fit` | `BoxFit` | contain | How sprite fits in bounds |
| `width` | `double?` | - | Fixed width |
| `height` | `double?` | - | Fixed height |
| `controller` | `SpriteAnimationController?` | - | External controller |
| `onFrame` | `ValueChanged<int>?` | - | Frame change callback |
| `onComplete` | `VoidCallback?` | - | Completion callback |

### SpriteAnimationController

| Method | Description |
|--------|-------------|
| `play()` | Start or resume playback |
| `pause()` | Pause at current frame |
| `stop()` | Stop and reset to frame 0 |
| `goToFrame(int)` | Jump to specific frame |
| `setAnimation(String, {SpriteAtlas})` | Switch named animation |
| `dispose()` | Clean up resources |

### SpriteAtlas

| Method | Description |
|--------|-------------|
| `SpriteAtlas.fromJson(String)` | Parse from JSON string |
| `SpriteAtlas.fromAsset(String)` | Load from Flutter asset |
| `getAnimation(String)` | Get animation data by name |
| `animationNames` | List of available animation names |

## License

MIT
