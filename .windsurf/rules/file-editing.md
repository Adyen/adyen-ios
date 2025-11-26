# Windsurf/Cascade Specific Tips

This file contains guidance specific to working with Windsurf and the Cascade AI assistant. For general project information, architecture, and development practices, see [AGENTS.md](AGENTS.md).

## File Editing in Windsurf

### Critical: Test Files Require Special Handling

The `edit` and `multi_edit` tools in Windsurf trigger automatic formatters that reformat entire files, creating massive diffs (hundreds of lines) even for small changes. This makes PRs impossible to review.

### Shell Command Technique for Test Files

Use shell commands for precise, line-by-line replacements:

```bash
# 1. Write new content to temp file
write_to_file("/tmp/new_test_method.txt", "new test content here")

# 2. Reassemble file with surgical replacement
head -87 original.swift > /tmp/part1.txt        # Lines before change
cat /tmp/new_test_method.txt >> /tmp/part1.txt  # New content
tail -n +168 original.swift >> /tmp/part1.txt   # Lines after change
mv /tmp/part1.txt original.swift                # Replace original
```

**Why this works:**
- No formatters are triggered
- Only the exact lines you specify are changed
- Preserves all existing formatting and whitespace
- Creates clean, reviewable diffs (e.g., 28 insertions/76 deletions vs 224 insertions/140 deletions)

**Steps:**
1. Identify line numbers: Use `read_file` to find start/end of section to replace
2. Create new content: Use `write_to_file` to `/tmp/` with new content
3. Calculate tail offset: `end_line + 1` (e.g., if test ends at line 167, use `tail -n +168`)
4. Execute replacement: Single command with `head`, `cat`, `tail`, `mv`
5. **Always clean up temp files** after completion

**Example from real usage:**
```bash
# Replaced 94-line test method with clean 32-line version
# Result: +28 insertions, -76 deletions (pure logical changes)
# No formatting noise in the 358-line file
```

### File Editing Guidelines

**For test files:**
- ❌ **NEVER use edit or multi_edit tools** - They cause massive formatting changes
- ✅ **Use shell command technique** as documented above
- ✅ **Always run tests immediately** after rewriting to verify they work
- ✅ **Clean up temp files** (`rm -f /tmp/*.txt`, patch files, etc.)

**For implementation files:**
- ✅ Use edit/multi_edit tools as needed
- ✅ Always run SwiftFormat after edits: `swiftformat path/to/file.swift`

### Command Execution

**CRITICAL - Avoid heredoc syntax:**
- ❌ **NEVER use heredoc** (`cat > file << 'EOF'`) - These commands hang indefinitely in Windsurf
- ✅ **Use write_to_file tool** for creating new files
- ✅ **Use edit tool** for modifying existing implementation files (not test files)
- ✅ **Use direct commands** without heredoc for all other operations

### Test-Driven Development

When refactoring or rewriting tests:
1. **Always run tests immediately after changes** - Use `xcodebuild test` with the appropriate scheme
2. **Verify compilation and passing status** - Never assume tests work without running them
3. **Report test results** - Show output to confirm success or diagnose failures

**Running specific tests:**
```bash
# Run a single test class
xcodebuild test -project Adyen.xcodeproj -scheme IntegrationUIKitTests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:IntegrationTests/CardComponentTests

# Run a single test method
xcodebuild test -project Adyen.xcodeproj -scheme IntegrationUIKitTests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:IntegrationTests/CardComponentTests/testUIConfiguration
```

## Cleanup Checklist

Before marking work complete:
- [ ] All temp files removed (`/tmp/*.txt`, patch files)
- [ ] All tests run and passing
- [ ] SwiftFormat applied to edited implementation files
- [ ] Git status clean (no unintended files)

## See Also

- [AGENTS.md](AGENTS.md) - Generic guidance for all AI assistants
- [TESTING.md](TESTING.md) - Testing guide and patterns
