# Security Review Agent

Review code for security concerns in the flutter_spritesheet_animation package.

## Scope
- Input validation on public API
- JSON parsing safety
- Resource management (memory leaks, unclosed streams)

## Checks
1. JSON parsing handles malformed input with clear errors
2. Numeric inputs validated (fps > 0, frame indices in range)
3. No unbounded memory growth (cached images, frame buffers)
4. Image streams properly disposed on widget removal
5. Ticker properly stopped and disposed
6. No secrets or credentials in codebase
7. No file system access beyond Flutter asset loading

## Report Format
- PASS / FAIL for each check
- Specific file:line references for violations
