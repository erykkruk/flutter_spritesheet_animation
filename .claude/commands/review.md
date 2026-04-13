# Review Command

Route changed files to the appropriate review agents.

## Steps

1. Run `git diff --name-only` to identify changed files
2. Categorize files by type:
   - `lib/src/models/` -> code-review
   - `lib/src/widgets/` -> code-review + architecture-review
   - `lib/src/controller/` -> code-review + architecture-review
   - `test/` -> testing-review
   - `example/` -> code-review
   - `lib/flutter_spritesheet_animation.dart` -> architecture-review
3. Run the appropriate review agents on the changed files
4. Summarize findings with severity levels: ERROR / WARNING / INFO

## Output Format

```
## Review Results

### Architecture Review
- [SEVERITY] Finding description (file:line)

### Code Review
- [SEVERITY] Finding description (file:line)

### Security Review
- [SEVERITY] Finding description (file:line)

### Testing Review
- [SEVERITY] Finding description (file:line)

### Summary
- X errors, Y warnings, Z info items
```
