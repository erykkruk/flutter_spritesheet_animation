# CLAUDE.md

## Overview

`flutter_spritesheet_animation` is a lightweight Flutter package for spritesheet animation. Supports grid-based and JSON atlas (TexturePacker, Aseprite) spritesheets with named animations, playback modes, and an external controller. Zero external dependencies.

## Tech Stack

| Category | Technology | Version |
|----------|-----------|---------|
| Language | Dart | >=3.0.0 <4.0.0 |
| Framework | Flutter | >=3.0.0 |
| Linting | flutter_lints | ^6.0.0 |

## Development Commands

```bash
dart pub get
dart analyze
dart format .
dart test
dart pub publish --dry-run
```

## Directory Structure

```
lib/
├── flutter_spritesheet_animation.dart   # Barrel export
└── src/
    ├── models/
    │   ├── models.dart                  # Barrel
    │   ├── play_mode.dart               # forward, reverse, pingPong
    │   ├── sprite_frame.dart            # Single frame data
    │   ├── sprite_animation_data.dart   # Animation sequence
    │   └── sprite_atlas.dart            # JSON atlas parser
    ├── controller/
    │   ├── controller.dart              # Barrel
    │   └── sprite_animation_controller.dart  # Playback controller
    └── widgets/
        ├── widgets.dart                 # Barrel
        └── sprite_animation.dart        # Main widget + CustomPainter
```

## Architecture Pattern

Library pattern with barrel exports:

```
Public API (lib/flutter_spritesheet_animation.dart)
    ↓
Widgets (CustomPaint + CustomPainter)
    ↓
Controller (ChangeNotifier + Ticker)
    ↓
Models (immutable data classes)
```

## Naming Conventions

| Context | Convention | Example |
|---------|-----------|---------|
| Files | snake_case | `sprite_frame.dart` |
| Classes | PascalCase | `SpriteFrame` |
| Functions | camelCase | `goToFrame()` |
| Enums | PascalCase.camelCase | `PlayMode.pingPong` |

## Error Handling

- `FormatException` for invalid JSON in `SpriteAtlas.fromJson()`
- `ArgumentError` for invalid values (negative fps, unknown animation names)
- `debugPrint` for non-fatal image loading errors

## Anti-patterns

- **NEVER** allocate objects in `paint()` — reuse Paint, pre-compute rects
- **NEVER** use `dynamic` types
- **NEVER** use `print()` — use `debugPrint` only
- **NEVER** expose `src/` internals — use barrel exports
- **NEVER** skip `const` on immutable constructors
- **NEVER** forget to dispose Ticker/streams

## Best Practices

- **ALWAYS** pre-compute frame rects at load time, not during paint
- **ALWAYS** reuse Paint objects across frames
- **ALWAYS** use barrel exports at each module level
- **ALWAYS** use `const` constructors where possible
- **ALWAYS** document public API with `///` doc comments
- **ALWAYS** run `dart analyze` with zero warnings before commit
- **ALWAYS** write tests alongside implementation

## Claude Code Integration

### Agents

| Agent | Purpose |
|-------|---------|
| architecture-review | Library structure, layers, barrel exports |
| code-review | Dart quality, naming, type safety |
| security-review | Input validation, resource management |
| testing-review | Test quality and coverage |

### Commands

| Command | Purpose |
|---------|---------|
| `/commit` | Conventional commits with pre-checks |
| `/pr` | Structured pull request |
| `/review` | Route files to review agents |
| `/quality-check` | Full pipeline: format + analyze + test |
