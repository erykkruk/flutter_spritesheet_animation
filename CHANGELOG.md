## 1.1.0

- Added `SpriteAnimationController.speed`, a playback multiplier that scales
  the whole animation clock. Unlike `fps`, it also applies to atlas
  animations whose frames carry their own durations, where the frame rate is
  fixed by the data and `fps` is ignored.
- Added `SpriteAnimationController.repeatCount`: play a looping animation a
  fixed number of times, then fire `onComplete`. Null keeps the previous
  unlimited behaviour. Changing it resets `completedCycles`, so a new limit
  applies from now rather than counting cycles that already ran.
- Added `completedCycles` and the `onCycle` callback, which fires on every
  wrap of a looping animation with the number completed so far.
- Added CI: `ci.yml` (format, analyze, test), `release.yml` (tag on version
  change) and `publish.yml` (pub.dev via OIDC). This was the only package in
  the workspace without them.
- Added `example/assets/sprite_demo.png`, a generated 8x8 / 64-frame
  spritesheet, and pointed the example at it. The example previously
  referenced `assets/backpack.png`, which is gitignored and was never
  committed, so the demo could not run from a clone and `flutter analyze`
  warned about the missing asset directory. The gitignore entry is left
  alone.

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
