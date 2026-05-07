# Git Helpers

## `anonymize-unpushed-commit-emails.sh`

Rewrite the author and committer email addresses for commits on the current
branch that have not been pushed to the upstream branch yet.

This is meant for the common case where you have a stack of local commits and
want to remove a real email address before pushing.

### What It Does

- Detects the current branch's upstream ref, or uses the one passed with
  `--upstream`
- Finds the commit range `upstream..HEAD`
- Prints a dry-run summary by default
- Optionally creates a backup branch before rewriting
- Rewrites `author email` and `committer email` in the target commits
- Optionally rewrites `author name` and `committer name` too

### Default Behavior

- Dry-run only
- Current branch only
- Unpushed commits only
- Replacement email: `anonymous@users.noreply.invalid`
- Requires a clean worktree unless `--allow-dirty` is passed
- Creates a backup branch unless `--no-backup` is passed

### Basic Usage

Preview what would change:

```bash
scripts/git/anonymize-unpushed-commit-emails.sh
```

Execute the rewrite:

```bash
scripts/git/anonymize-unpushed-commit-emails.sh --execute
```

Allow a dirty worktree:

```bash
scripts/git/anonymize-unpushed-commit-emails.sh --allow-dirty --execute
```

Use a custom anonymous email:

```bash
scripts/git/anonymize-unpushed-commit-emails.sh \
  --email anon@example.invalid \
  --execute
```

Rewrite both email and name:

```bash
scripts/git/anonymize-unpushed-commit-emails.sh \
  --email anon@example.invalid \
  --name Anonymous \
  --execute
```

Use an explicit upstream instead of `@{upstream}`:

```bash
scripts/git/anonymize-unpushed-commit-emails.sh \
  --upstream origin/master \
  --execute
```

### Options

```text
--email <email>     Replacement email for author and committer
--name <name>       Replacement name for author and committer
--upstream <ref>    Compare against this ref instead of @{upstream}
--allow-dirty       Skip the clean-worktree safety check
--no-backup         Do not create a backup branch before rewriting
--execute           Actually rewrite history
--help              Show help
```

### Recommended Workflow

1. Run the script without `--execute`
2. Check the printed commit list and unique email list
3. Re-run with `--execute`
4. Verify the rewritten range
5. Push with `--force-with-lease` if needed

Verification command:

```bash
git log --format='%h %an <%ae> | %cn <%ce> | %s' @{upstream}..HEAD
```

If the branch history was already pushed somewhere and you need to update the
remote branch:

```bash
git push --force-with-lease
```

### Safety Notes

- This rewrites Git history. Commit hashes will change.
- Only the commits in `upstream..HEAD` are rewritten.
- Code content is not edited; only commit metadata changes.
- The backup branch is your quick rollback point.

### Rollback

If you used the default backup behavior, the script prints a backup branch name
like:

```text
backup/anonymize-emails-20260507-155532
```

To inspect it:

```bash
git log --oneline backup/anonymize-emails-20260507-155532 -5
```

To reset your branch back to that exact history:

```bash
git branch -f master backup/anonymize-emails-20260507-155532
git switch master
```

Replace `master` with your current branch if needed.

### When Not To Use This Script

- You only need to fix the latest commit
- You want to rewrite already-shared public history for many branches
- You need repository-wide filtering instead of current-branch unpushed commits

For only the latest commit, `git commit --amend` is simpler.
