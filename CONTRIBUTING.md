# Contribution guidelines

## How to contribute step-by-step

1. Fork this repository.
2. Create a new branch from `develop` in your fork. This makes it easier for you to keep track of your changes.
3. Make the desired changes to the code.
    * If you are adding new functionality or fixing a bug, we recommend you add unit tests that cover it.
    * We advice you to follow our [Git commit message structure](#git-commit-message-structure)
4. Push the changes to your fork.
5. Create a pull request.
6. In your pull request, please describe in detail:
    * What problem you’re solving
    * Your approach to fixing the problem
    * Any tests you wrote
7. Check Allow edits from maintainers.
8. Create the pull request.
9. Ensure that all checks have passed.

After you create your pull request, one of the code owners will review your code.
We aim to review your request within 2-3 business days.

## Git commit message structure 

`[purpose]: [Commit message: starts with verb, imperative mood] `

- **feature** - for public API increments
- **deprecate** - for deprecated public API flagging
- **remove** - for deprecate API decrements
- **docs** - for documentation increments
- **chore** - for non-public API changes or refactoring
- **fix** - for bug fixes

Example:

```
chore: Update tests
deprecate: Deprecate method xxx(aaa) in YYYY
feature: Add method xxx(aaa:bbb) to YYYY
chore: Fix typo in meta-docs
```
