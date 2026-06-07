## 1.0.3

- Added `PlayModeX` extension with `isForward`, `isReverse` and `isPingPong`
  convenience getters on `PlayMode`.

## 1.0.2

- `SpriteAnimationController` constructor now validates `fps` immediately
  (throws `ArgumentError` when `fps <= 0`). Previously the assertion only
  ran when callers later mutated `fps` through the setter.
- Extracted hot-loop magic numbers into named constants
  (`_kMicrosecondsPerSecond`, `_kMicrosecondsPerMillisecond`) inside the
  tick accumulator — no behavioural change, just readability.

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
