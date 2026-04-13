# Testing Review Agent

Review test quality and coverage for the flutter_spritesheet_animation package.

## Scope
- Test completeness and coverage
- Test patterns (AAA: Arrange, Act, Assert)
- Test isolation and independence
- Edge case coverage

## Checks
1. Every public class has a corresponding test file
2. Tests follow AAA pattern
3. Tests are independent (no shared mutable state between tests)
4. setUp/tearDown properly initialize and clean up
5. Edge cases tested: zero frames, single frame, invalid indices
6. Async/Ticker tests use proper Flutter test utilities (testWidgets, pump)
7. Error cases tested: invalid JSON, missing animations, negative fps
8. Widget tests verify lifecycle (init, update, dispose)
9. Coverage target: >80% line coverage

## Report Format
- PASS / FAIL for each check
- Missing test scenarios listed
- Specific file:line references for issues
