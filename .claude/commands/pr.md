# PR Command

Create a structured pull request for flutter_spritesheet_animation changes.

## Steps

1. Check current branch and ensure it's not `main`
2. Run full quality check (analyze, format, test)
3. Review all commits since diverging from main
4. Create PR with structured template

## PR Template

```markdown
## Summary
<1-3 bullet points describing the change>

## Changes
- List specific files and what changed

## Type
- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation
- [ ] Test

## Checklist
- [ ] `dart analyze` passes with zero warnings
- [ ] `dart format` applied
- [ ] Tests pass
- [ ] Public API documented
- [ ] Example updated (if API changed)
- [ ] CHANGELOG.md updated

## Test Plan
<How to verify this change>
```
