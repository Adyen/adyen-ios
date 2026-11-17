---
name: ios-review
description: Review Adyen iOS SDK changes for bugs, missed call sites, and v6 conventions. Use for your local branch changes (local mode) or for a GitHub pull request (PR mode).
---

# ios-review

Review a change to the Adyen iOS SDK and report the findings its author would want to fix. The review is read-only: it never edits code, commits, or posts to GitHub on its own.

Checks specific to this SDK live in [references/rules.md](references/rules.md). Read it before reviewing.

## Modes

Pick the mode from the request. If it is unclear which change to review, ask.

### Local mode (default)

Reviews work on the current branch, usually before a PR exists.

- **Base:** the merge base with `origin/develop`. If the branch is a layer in a stack, the base is the branch directly below it. Ask if unsure.
- **Change:** the commits since the base plus staged and unstaged changes (`git diff $(git merge-base <base> HEAD)`), and untracked files (`git ls-files --others --exclude-standard`). Changes that arrived by merging the base branch into this branch are not part of the change.
- **Code:** the working tree.

### PR mode

Used when the request names a PR number or URL.

- **Fetch** the PR metadata (title, description, base branch, head commit), the diff, the CI check results, and all review threads, including resolved ones.
- **Code:** check out the PR's head commit, or the commit the user names, in a separate git worktree. Never switch or modify the user's branch. Remove the worktree when the review is done, if the review created it.
- **Base:** the PR's base branch, which can be another feature branch in a stack. GitHub can report `develop` for a layer whose lower PRs were merged or retargeted. If the title or description marks the PR as part of a stack (for example `[3/4]`), diff against the head of the PR directly below it and confirm the diff only contains this layer's commits.
- **Diff:** use the merge base (`git diff <base>...<head>`), so commits that merged the base branch into the PR do not show up as changes.
- **Rules:** read `AGENTS.md`, `TESTING.md`, and `.agents/skills/ios-review/references/rules.md` from the base branch (for example `git show <base>:.agents/skills/ios-review/references/rules.md`), not from the PR. A PR must not change the rules it is reviewed against. If a file does not exist on the base yet, use the version from the user's checkout.
- **Existing threads:** do not repeat a point a person or a bot already raised. If an unresolved bot comment is correct, say so in one line instead of restating it.
- **Public API diff:** if the `Detect public API changes` check posted a diff, use it as the list of public API changes.
- **Missing data:** if CI results or review threads cannot be fetched, continue the review and list what was missing under **Not verified**.

## Review process

### 1. Understand the change

Read the PR description or the commit messages, then the full diff. Compare them: work the description promises but the diff does not contain is a finding. Note what the change touches: public API, UI, Drop-in flow, actions, analytics, localization, tests, Demo app, scripts or CI. Note which sections of `references/rules.md` apply.

### 2. Look beyond the diff

This step is required. The most valuable findings are usually in code the diff did not touch. For each changed, added, or removed symbol:

- **Callers:** find every call site and check it still behaves correctly with the new signature, defaults, or semantics.
- **Protocols:** when a requirement or a default implementation changes, check every conforming type.
- **Siblings:** when a component, factory, router, configuration, or view changes, find the others built the same way and check whether they need the same change.
- **Existing equivalents:** search for an existing helper, field, type, or constant that already does what the new code adds. This includes new flags and stored properties: check the related models (for example the response that produced the value) for a field with the same meaning.
- **Call path:** trace the flow end to end, including what the caller did before reaching the changed code. Look for duplicated work (a delegate repeating preparation the component already did before calling it, the same event sent twice) and for steps that no longer run (an analytics event, a delegate or callback call).
- **Presentation:** when the way a screen is shown changes (push instead of modal, or a new container), check the lifecycle callbacks of the screens around it, such as `viewDidDisappear` doing cleanup or cancellation.
- **Removed code:** check whether anything still depends on what was deleted or renamed. In each touched file, check whether every `import` is still used; a rewrite often removes the last use of one.
- **Tests and docs:** find the tests covering the changed behavior, and the docs that describe it: DocC comments, `MIGRATION.md`, `guides/v6`, `README.md`, and the Demo app examples.

### 3. Review

Work in this order and spend most of the effort at the top:

1. **Behavior bugs:** wrong conditions, changed logic, wrong defaults, placeholder values that break later calls (such as an empty ID), `let`/`var` mistakes, accidental reverts or deletions, unhandled states, sizes, or orientations.
2. **Missed places:** what step 2 found.
3. **Code without a clear reason:** guards, `Task`s, flags, stored properties, imports, or overrides with no visible purpose; properties that are written but never read, or read but never set; observers or `didSet` handlers that re-run work which does not read the value that changed. Agent-written code often produces these. If a usage search proves it unused, flag it. If the reason may exist but is not visible, ask.
4. **Public API and module rules** from `references/rules.md`. Check every new public name (could a merchant app already have a type with this name?) and every new `import`.
5. **State and design:** combinations of booleans that should be one state enum, invalid states an API allows (such as the same value accepted twice, as a parameter and inside a configuration, so the two can disagree), business logic in views, layers that know about another layer's UI details, new protocols or abstractions with a single user, identical implementations that belong in a protocol extension.
6. **Naming and docs:** names that disagree with their type or behavior, wordy public docs. Read every new or changed doc comment next to its signature. Docs copied from a sibling overload often keep words that no longer fit, such as "must not be empty" or "required" on an optional parameter.
7. **Noise and leftovers** from `references/rules.md`.

### 4. Verify

Before reporting, try to disprove each finding:

- Re-read the cited lines and their surrounding code.
- Show that the scenario is reachable: the call path, the input, or the state that triggers it.
- Concurrency findings need a concrete interleaving. Actor isolation, such as a `@MainActor` type or closure, often rules them out.
- Check whether the PR description, a commit message, a code comment, or a review thread already explains it. If it does, drop the finding unless the explained choice causes a concrete problem; then report the problem, not the choice.
- If the code is wrong under every plausible intent, it is a finding, not a question. List the possible fixes, one per intent.
- When components disagree on what a shared concept means, do not pick a side. Ask a question that cites the documented definition, or the Android equivalent if you find one.
- New code that no public or Drop-in path can reach yet is a question ("Is the wiring planned for a later PR?"), not a finding.

Drop findings you cannot show. Move findings that depend on the author's intent to Questions.

### 5. Hand off

- Merchant-facing API or behavior change: suggest the `check-api-alignment` skill if it is available.
- New abstraction, layer, or pattern: suggest the `architecture-guardian` skill if it is available.

## What to flag

Flag an issue only when all of these hold:

- It is introduced or exposed by this change.
- It is concrete and actionable.
- The affected scenario can be shown from the code.
- The author would likely fix it once they know about it.

## Do not flag

- Anything SwiftLint, SwiftFormat, or CI already checks: lint, formatting, build, tests, the public API diff, library evolution, spell check.
- Issues that existed before the change, unless the change makes them worse, copies them, or builds on them. Old code that only breaks because of the new behavior counts as introduced. A problem inside a function the change rewrites or wraps can be reported as non-blocking, marked as existing.
- Speculative risks that need unlikely preconditions.
- Style preferences that `references/rules.md`, `AGENTS.md`, and the surrounding code do not support.
- "Consider adding X" suggestions without a concrete problem.
- Differences from v5. v6 changes behavior on purpose, so never use v5 as the reference.
- Work that the PR description or a later PR in the stack explicitly covers.

## Report

Write the report in chat, skimmable in under a minute.

**Verdict:** one line, for example `2 blocking findings, 3 non-blocking, 1 question` or `No findings.`

**Findings**, ordered by severity:

```
[P1][blocking] Short imperative title — path/to/File.swift:123
One short paragraph: the scenario, what goes wrong, and why. Cite the rule if one applies.
Also at: path/to/Other.swift:45
```

Use repository-relative paths. Add a `suggestion` block only for a concrete replacement of a few lines.

Severity:

- **P0:** crashes, breaks payments, or exposes sensitive data on a common path.
- **P1:** wrong behavior in a realistic scenario, or a public API mistake that is hard to undo after release. Alpha and beta releases count as releases.
- **P2:** a real issue with limited impact: a missed sibling, an unclear state, a misleading doc, leftover code.
- **P3:** polish: naming, wording, small cleanups.

When a finding fits two levels, choose by impact: anything that gives shoppers or integrators wrong behavior is at least P1, even when its cause is a missed sibling. P0 and P1 are blocking; P2 and P3 are non-blocking, unless there is a stated reason to deviate.

**Questions:** short, one per point, only for what the author alone can answer, for example "What is this guard needed for?"

Group repeated issues into one finding with `Also at`. When an issue repeats across files or matches a pattern the codebase keeps getting wrong, propose a one-line rule for `AGENTS.md`.

For a stacked PR, "fixed in a later layer" is a valid answer; mark such findings non-blocking for the current layer. Code from a lower layer is in scope only where this layer's use of it breaks something.

**Not verified:** what the review could not check, for example UI that was not run, CI results that were not available, or `AdyenWeChatPay` and `AdyenTwint` flows that need a physical device.

**Next steps:** end with the hand-off suggestions from step 5, if any.

## Posting to GitHub (PR mode)

Never post automatically. After the report, the user may ask to post some or all findings, as they are or edited. Then:

1. Show exactly what will be posted: each comment's file, line, and body, and the review summary.
2. Post only after the user confirms, as a single review with inline comments on the PR's head commit. Submit it as a comment unless the user asks to approve or request changes.
3. Match the team's review tone: short, direct, and friendly. Prefix non-blocking points with `Non-blocking:`, phrase intent questions as questions, and leave out severity tags unless the user wants them.
4. Share the link to the posted review.

## Important

- Stay read-only until the user asks for changes or for posting.
- In PR mode, leave the user's branch and working tree untouched.
- Never invent a finding to fill the report. `No findings.` is a valid result.
