## 1.0.0

- Initial release.
- Grid-based spritesheet animation (`SpriteAnimation.grid`).
- JSON atlas animation (`SpriteAnimation.atlas`) with TexturePacker and Aseprite support.
- Named animations via `frameTags`.
- `SpriteAnimationController` with play/pause/stop/goToFrame.
- Playback modes: forward, reverse, pingPong.
- Per-frame duration from atlas data.
- Pre-computed grid rects for optimal rendering performance.
- Reusable Paint object to avoid per-frame allocations.
- Zero external dependencies (Flutter SDK only).
