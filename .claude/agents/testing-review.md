# Testing Review Agent

## Role
Validate test quality and coverage for the `flutter_spritesheet_animation` library.

## Scope
- Unit tests for models and controller
- Widget tests for SpriteAnimation
- Test patterns and best practices

## Checklist

### Test Structure
- [ ] Tests mirror `lib/src/` structure in `test/`
- [ ] Each public class has corresponding test file
- [ ] Test file naming: `{class_name}_test.dart`
- [ ] Tests grouped logically with `group()`

### Test Quality
- [ ] AAA pattern: Arrange, Act, Assert
- [ ] One assertion concept per test
- [ ] Descriptive test names
- [ ] Edge cases covered (null, empty, boundary values)
- [ ] Error cases tested

### Model Tests
- [ ] Atlas parsing tested for both formats (TexturePacker hash, Aseprite array)
- [ ] Frame tag extraction tested
- [ ] Trimmed frame data tested
- [ ] Invalid JSON error handling tested

### Controller Tests
- [ ] Initial state validated
- [ ] Configuration setters tested (fps, mode, loop)
- [ ] Play/pause/stop state transitions tested
- [ ] Frame advancement with ticker tested
- [ ] Forward/reverse/pingPong modes tested
- [ ] goToFrame clamping tested

### Widget Tests
- [ ] Grid and atlas constructors tested
- [ ] isGrid property tested
- [ ] Empty SizedBox during loading tested
- [ ] External controller integration tested

### Coverage
- [ ] All public API methods tested
- [ ] All model constructors and factories tested
- [ ] Edge cases: empty data, boundary values, malformed input
