# Quality Check Command

Run the full quality pipeline for flutter_spritesheet_animation.

## Steps (sequential)

1. **Format**: `dart format .`
2. **Analyze**: `dart analyze` (must pass with zero warnings)
3. **Test**: `flutter test` (all tests must pass)
4. **Dry run**: `dart pub publish --dry-run`

## Expected Output

```
## Quality Check Results

| Step      | Status | Details         |
|-----------|--------|-----------------|
| Format    | PASS   | 0 files changed |
| Analyze   | PASS   | 0 warnings      |
| Test      | PASS   | X tests passed  |
| Publish   | PASS   | ready           |

Overall: PASS / FAIL
```

## On Failure
- Report which step failed
- Show the specific errors
- Suggest fixes
