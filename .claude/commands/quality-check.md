# Quality Check Command

Full quality pipeline for the package.

## Steps
1. `dart format . --set-exit-if-changed` — verify formatting
2. `dart analyze` — zero warnings
3. `dart test` — all tests pass
4. `dart pub publish --dry-run` — validate publishability
