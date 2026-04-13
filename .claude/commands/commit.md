# Commit Command

Run pre-commit checks and create a conventional commit.

## Steps

1. Run `dart analyze` in the package directory
2. Run `dart format --set-exit-if-changed .` to verify formatting
3. Run `flutter test` if test files exist
4. If all checks pass, stage changes and create a conventional commit

## Commit Format

```
<type>(<scope>): <description>

<body>
```

### Types
- `feat` - new feature/widget/API
- `fix` - bug fix
- `refactor` - code restructuring without behavior change
- `docs` - documentation only
- `test` - test additions or changes
- `chore` - build, CI, tooling changes
- `perf` - performance improvement

### Scopes
- `widget` - SpriteAnimation widget
- `controller` - SpriteAnimationController
- `models` - data models and atlas parsing
- `example` - example app
- `docs` - documentation
