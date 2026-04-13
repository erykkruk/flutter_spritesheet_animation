# Architecture Review Agent

## Role
Validate architecture and module structure for the `flutter_spritesheet_animation` library.

## Scope
- Library structure (barrel exports, src/ organization)
- Widget composition and rendering pipeline
- Controller design (ChangeNotifier + Ticker)
- Dependency direction (no circular imports)
- Public API surface design

## Checklist

### Library Structure
- [ ] Single barrel export in `lib/flutter_spritesheet_animation.dart`
- [ ] All implementation in `lib/src/`
- [ ] Models in `lib/src/models/` with `models.dart` barrel
- [ ] Widgets in `lib/src/widgets/` with `widgets.dart` barrel
- [ ] Controller in `lib/src/controller/` with `controller.dart` barrel
- [ ] No circular dependencies between modules

### Public API
- [ ] Only public types exported from barrel file
- [ ] Implementation details hidden in `src/`
- [ ] Clean, minimal public surface
- [ ] All public APIs documented with `///` doc comments

### Widget Design
- [ ] Uses `CustomPainter` with `repaint: Listenable` for frame updates
- [ ] No `setState()` per frame
- [ ] Pre-computed frame rects (no calculations in `paint()`)
- [ ] Reusable `Paint` object across frames
- [ ] Proper `dispose()` cleanup (image stream, controller, ticker)
- [ ] Supports both owned and external controllers

### Controller Design
- [ ] Extends `ChangeNotifier` for `repaint` listenable
- [ ] Ticker-based frame advancement
- [ ] Zero-allocation hot loop (raw microsecond arithmetic)
- [ ] Accumulator pattern for frame-accurate timing
- [ ] Supports grid and atlas modes

### Model Design
- [ ] Immutable data classes with `const` constructors
- [ ] Factory methods for JSON parsing
- [ ] No `dynamic` types
