---
name: ent:release-tag
description: Release the latest Ent_TestFlight_X.Y.BUILD tag: merge it into master, tag master Ent_X.Y.BUILD, and create a GitHub release named vX.Y (e.g. Ent_TestFlight_14.3.3398 -> v14.3).
argument-hint: [--dry-run] [testflight-tag-name]
allowed-tools: Bash, Read
---

Promote a Bitrise TestFlight tag to a production release of the iOS app.

## Dry run

If the arguments contain `--dry-run`, run steps 1 and 2 (read-only; `git fetch` is allowed) and, for steps 3-6, only **print** the exact commands that would run, with resolved values. Additionally simulate the merge without touching anything: `git merge-tree --write-tree master $TESTFLIGHT_TAG` (reports conflicts, if any) and `git log --oneline master..$TESTFLIGHT_TAG`. Do not checkout, merge, tag, push, or call `gh release create`. End with "DRY RUN — nothing was changed". The other arguments are parsed after removing `--dry-run`.

## Tag format

Bitrise creates `Ent_TestFlight_$XBV_PROJECT_VERSION` (see `bitrise.yml`), where the version is `MAJOR.MINOR.BUILD` (e.g. `14.3.3398`).

- `MAJOR` = first number, `MINOR` = second number, `BUILD` = third number
- Release tag on master: `Ent_MAJOR.MINOR.BUILD` (same suffix, `TestFlight_` removed)
- Release name: `v<MAJOR>.<MINOR>`

Examples: `Ent_TestFlight_14.3.3398` -> tag `Ent_14.3.3398`, release `v14.3`; `Ent_TestFlight_13.2.3111` -> `Ent_13.2.3111`, `v13.2`.

## Steps

### 1. Preconditions

- Remember the current branch: `ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)`.
- `gh auth status` must succeed.
- `git fetch origin --tags --prune`
- Uncommitted changes are stashed in step 4 (not here), after the user has confirmed. In a dry run, just list them with `git status --porcelain` and say they would be stashed.

### 2. Resolve the TestFlight tag

- If a tag name is given (after removing `--dry-run`), use it as `TESTFLIGHT_TAG` (must match `^Ent_TestFlight_[0-9]+\.[0-9]+\.[0-9]+$`).
- Otherwise take the highest one by version: `git tag --list 'Ent_TestFlight_*' | sort -V | tail -1`
- Parse `MAJOR`, `MINOR`, `BUILD` from the suffix, then `VERSION_TAG=Ent_$MAJOR.$MINOR.$BUILD` and `RELEASE_NAME=v$MAJOR.$MINOR`.
- If `VERSION_TAG` already exists (locally or on origin), stop and report — never overwrite a tag.
- If a GitHub release named `$RELEASE_NAME` already exists (`gh release view $RELEASE_NAME`), warn the user in step 3 (a new build of the same minor version) and suggest a suffix such as `v$MAJOR.$MINOR.1` before continuing.

### 3. Confirm with the user

Show a summary and wait for approval, because the next steps push to origin and publish a release:

- TestFlight tag, commit it points to
- Number of commits it brings into master (`git log --oneline master..$TESTFLIGHT_TAG | wc -l`)
- `VERSION_TAG` and `RELEASE_NAME`

### 4. Merge into master

If `git status --porcelain` is not empty, stash first (tracked and untracked files):

```
git stash push --include-untracked -m "release-tag auto-stash"
```

Then:

```
git checkout master
git pull --ff-only origin master
git merge $TESTFLIGHT_TAG -m "Merge tag '$TESTFLIGHT_TAG'"
```

- Fast-forward is fine when possible (git will do it without creating a merge commit).
- On conflicts: stop, leave the state for the user and explain (mention that the auto-stash is still in `git stash list`). Do not resolve silently.

### 5. Tag master

```
git tag $VERSION_TAG master
git push origin master $VERSION_TAG
```

### 6. Create the GitHub release

```
gh release create $VERSION_TAG --title "$RELEASE_NAME" --generate-notes --verify-tag
```

`--generate-notes` builds notes from PRs/commits since the previous release.

### 7. Report

Print the release URL (`gh release view $VERSION_TAG --json url -q .url`) then restore the user's state: `git checkout $ORIGINAL_BRANCH`, and if a stash was created in step 4, `git stash pop`. If the pop conflicts, stop and tell the user (the stash is kept).

## Rules

- Never force-push, never delete or move existing tags.
- Do not create commits other than the merge commit in step 4.
