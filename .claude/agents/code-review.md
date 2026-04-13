# Code Review Agent

## Role
Validate Dart code quality for the `flutter_spritesheet_animation` library.

## Scope
- Dart code quality and style
- Type safety
- Naming conventions
- Import order
- Error handling patterns

## Checklist

### Dart Code Quality
- [ ] No `dynamic` types
- [ ] No `print()` — use `debugPrint` only
- [ ] No untyped collections
- [ ] `const` constructors where possible
- [ ] `final` for local variables
- [ ] Proper null safety (no unnecessary `!` operators)
- [ ] No unused imports or variables
- [ ] No object allocations in `paint()` method

### Naming
- [ ] Files: `snake_case.dart`
- [ ] Classes: `PascalCase`
- [ ] Functions/methods: `camelCase`
- [ ] Constants: `SCREAMING_SNAKE_CASE`
- [ ] Private members: `_prefixed`
- [ ] Descriptive, intention-revealing names

### Import Order
1. `dart:` SDK imports
2. `package:` third-party imports
3. Relative imports
- [ ] Alphabetically sorted within each group
- [ ] No unused imports

### Error Handling
- [ ] No swallowed exceptions
- [ ] `FormatException` for invalid JSON in atlas parsing
- [ ] `ArgumentError` for invalid values (negative fps, unknown animation)
- [ ] `debugPrint` for non-fatal image loading errors

### Documentation
- [ ] All public APIs have `///` doc comments
- [ ] Example code in doc comments for key classes
- [ ] No redundant comments
