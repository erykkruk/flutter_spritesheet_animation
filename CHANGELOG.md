## 1.0.1

- Fix: active ticker assertion on dispose with external controller.

## 1.0.0

- Initial release.
- Grid-based spritesheet animation (`SpriteAnimation.grid`).
- JSON atlas animation (`SpriteAnimation.atlas`) with TexturePacker and Aseprite support.
- Named animations via `frameTags`.
- `SpriteAnimationController` with play/pause/stop/goToFrame.
- Playback modes: forward, reverse, pingPong.
- Per-frame duration from atlas data.
- Image precaching (`SpriteAnimation.precache` / `precacheAll`).
- Zero widget rebuilds via `CustomPainter(repaint:)` — paint-layer-only updates.
- Zero-allocation tick loop with raw microsecond arithmetic.
- Pre-computed grid rects for optimal rendering performance.
- Reusable Paint object to avoid per-frame allocations.
- Zero external dependencies (Flutter SDK only).
