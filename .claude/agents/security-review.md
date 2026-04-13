# Security Review Agent

## Role
Validate security aspects of the `flutter_spritesheet_animation` library.

## Scope
- JSON parsing safety
- Input validation
- Resource management

## Checklist

### Input Validation
- [ ] JSON atlas parsing validates structure before access
- [ ] Frame indices clamped to valid range
- [ ] FPS validated as positive number
- [ ] Animation names validated against available animations
- [ ] Image dimensions validated (no division by zero)

### JSON Parsing Safety
- [ ] Uses typed models (not raw `Map<String, dynamic>`)
- [ ] `FormatException` thrown for malformed JSON
- [ ] Null-safe property access
- [ ] No arbitrary code execution from JSON data

### Resource Management
- [ ] Image streams properly disposed
- [ ] Ticker stopped and disposed
- [ ] Controller listeners removed
- [ ] No memory leaks from retained images

### Code Safety
- [ ] No hardcoded secrets, keys, or tokens
- [ ] Zero external dependencies (minimal attack surface)
- [ ] No `eval()` or dynamic code execution
