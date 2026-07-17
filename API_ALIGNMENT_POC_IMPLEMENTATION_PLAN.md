# API Alignment POC Implementation Plan

## Goal

Add an advisory, Card-only cross-platform API-alignment review to internal iOS pull requests. The review compares the compiler-backed iOS base-to-head public API diff with Android `main` Card API files and the meta-repo alignment contract.

## Scope

- Extend `.github/workflows/detect_api_changes.yml`.
- Use iOS `develop` as the target branch for this POC.
- Inspect `AdyenCard` changes only.
- Read Android `main` `card`, `bcmc`, and `giftcard` API files.
- Read alignment documents and accepted ADRs from meta-repo `develop`.
- Update one advisory PR comment for internal pull requests.

## Implementation phases

1. [x] Verify `AGENTS.md` targets `develop`; no edit was needed on the current branch.
2. [x] Preserve the existing macOS public API diff job and upload its generated diff as an artifact.
3. [x] Add a dependent Ubuntu review job that runs only for internal pull requests with `AdyenCard` public API changes.
4. [x] Assemble the review prompt from trusted meta-repo tooling, Android `main` API files, and the iOS diff artifact.
5. [x] Call Gemini as text-only inference and recreate the tagged advisory comment.
6. [x] Delete a stale advisory comment when a PR no longer changes the Card public API.

## Security constraints

- The macOS job executes PR code and has no model or meta-repo credentials.
- The review job runs on a separate runner and never checks out or executes PR code.
- The review job treats the uploaded API diff as untrusted text.
- The model call has no agent tools or repository access.
- The private meta-repo checkout uses the existing `AUTOMATION_BOT_TOKEN`; its access is verified by the workflow.

## Verification

- Validate YAML syntax and shell scripts statically.
- Confirm the workflow preserves the existing API-diff behavior.
- Confirm the review job is limited to internal PRs and Card API changes.
- Confirm comment recreation/deletion uses a distinct `api_alignment` tag.
- Run controlled PR or workflow-dispatch scenarios before relying on the advisory result.
