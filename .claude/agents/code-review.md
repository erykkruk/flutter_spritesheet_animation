# Code Review Agent

Review Dart code quality for the flutter_spritesheet_animation package.

## Scope
- Code style and naming conventions
- Type safety (no dynamic, no untyped collections)
- Import order and organization
- Error handling patterns
- Performance anti-patterns

## Checks
1. snake_case file names, PascalCase classes, camelCase methods
2. No `dynamic` types — always explicit
3. No `print()` — use `debugPrint` only in debug paths
4. All public APIs have `///` doc comments
5. `const` constructors where possible
6. No unnecessary allocations in hot paths (paint, tick)
7. Proper `dispose()` cleanup for Tickers, streams, listeners
8. Import order: dart:, package:flutter, package:self, relative

## Report Format
- PASS / FAIL for each check
- Specific file:line references for violations
