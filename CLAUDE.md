# In ./CLAUDE.md
@AGENTS.md

## Workflow Rules

**CRITICAL: Always plan first, never execute without explicit approval.**

1. When asked to implement a feature or change:
   - First create/update a plan document
   - Present the plan to the user
   - **WAIT for explicit approval** before making any code changes

2. Only proceed with implementation when the user says words like:
   - "proceed", "go ahead", "implement it", "approved", "looks good, do it"

3. If uncertain, always ask: "Should I proceed with implementation?"

## Code Editing Rules

**CRITICAL: The `edit` and `multi_edit` tools trigger an internal formatter that differs from SwiftFormat, causing massive formatting diffs.**

**Use shell commands instead:**

1. **Simple replacement:**
   ```bash
   sed -i '' 's/old/new/g' file.swift
   ```

2. **Add line after pattern:**
   ```bash
   sed -i '' '/pattern/a\
   new line' file.swift
   ```

3. **Multi-line insertion (using perl):**
   ```bash
   perl -i -0777 -pe 's/(pattern)/$1\nnew lines/' file.swift
   ```

4. **Replace entire function (head/tail approach):**
   ```bash
   head -n N file.swift > /tmp/part1.swift
   cat /tmp/new_content.swift >> /tmp/part1.swift
   tail -n +M file.swift >> /tmp/part1.swift
   mv /tmp/part1.swift file.swift
   ```

5. **Create temp files with heredoc:**
   ```bash
   cat > /tmp/new_code.swift << 'EOF'
   // content here
   EOF
   ```

**Do NOT use for Swift files:**
- ❌ `edit` tool
- ❌ `multi_edit` tool
- ❌ `write_to_file` for modifications

**Always verify with:**
```bash
git diff file.swift
```
