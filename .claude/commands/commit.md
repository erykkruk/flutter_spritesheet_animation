# Commit Command

Create a conventional commit with pre-commit checks.

## Steps
1. Run `dart format .` — fix any formatting issues
2. Run `dart analyze` — must have zero warnings
3. Run `dart test` — all tests must pass
4. Stage changed files
5. Create commit with conventional format:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `refactor:` for code restructuring
   - `test:` for test additions/changes
   - `docs:` for documentation changes
   - `chore:` for build/tooling changes
