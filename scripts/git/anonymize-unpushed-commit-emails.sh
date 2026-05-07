#!/usr/bin/env bash

set -euo pipefail

DEFAULT_ANON_EMAIL="anonymous@users.noreply.invalid"

usage() {
  cat <<'EOF'
Usage:
  scripts/git/anonymize-unpushed-commit-emails.sh [options]

Rewrite the author/committer email addresses for commits on the current branch
that have not been pushed to the configured upstream yet.

Defaults:
  - Dry-run only. Use --execute to actually rewrite history.
  - Rewrites only commits reachable from HEAD but not from the upstream branch.
  - Replaces both author and committer email with:
      anonymous@users.noreply.invalid

Options:
  --email <email>         Anonymous email to write into rewritten commits
  --name <name>           Also replace author/committer names with this value
  --upstream <ref>        Override the upstream ref instead of @{upstream}
  --allow-dirty           Skip the clean-worktree safety check
  --no-backup             Do not create a backup branch before rewriting
  --execute               Perform the rewrite
  --help                  Show this help text

Examples:
  scripts/git/anonymize-unpushed-commit-emails.sh
  scripts/git/anonymize-unpushed-commit-emails.sh --execute
  scripts/git/anonymize-unpushed-commit-emails.sh \
    --email anon@example.invalid \
    --name Anonymous \
    --execute
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_git_repo() {
  git rev-parse --git-dir >/dev/null 2>&1 || die "current directory is not a Git repository"
}

ensure_not_detached() {
  local branch
  branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  [[ -n "$branch" ]] || die "detached HEAD is not supported; check out a branch first"
  printf '%s\n' "$branch"
}

ensure_clean_worktree() {
  local status
  status="$(git status --short)"
  [[ -z "$status" ]] || die "worktree is not clean; commit or stash changes first, or pass --allow-dirty"
}

resolve_upstream() {
  local explicit_upstream="${1:-}"

  if [[ -n "$explicit_upstream" ]]; then
    git rev-parse --verify --quiet "$explicit_upstream^{commit}" >/dev/null \
      || die "upstream ref '$explicit_upstream' does not exist"
    printf '%s\n' "$explicit_upstream"
    return
  fi

  local upstream
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
  [[ -n "$upstream" ]] || die "current branch has no upstream; pass --upstream <ref>"
  printf '%s\n' "$upstream"
}

list_target_commits() {
  local upstream="$1"
  git rev-list --reverse "HEAD" "^${upstream}"
}

print_summary() {
  local upstream="$1"
  local anon_email="$2"
  local anon_name="$3"

  echo "Upstream: $upstream"
  echo "Target range: ${upstream}..HEAD"
  echo "Replacement email: $anon_email"
  if [[ -n "$anon_name" ]]; then
    echo "Replacement name: $anon_name"
  fi
  echo
  echo "Commits to rewrite:"
  git log --reverse --format='  %h  %an <%ae> | %cn <%ce> | %s' "HEAD" "^${upstream}"
  echo
  echo "Unique emails in target range:"
  git log --format='%ae%n%ce' "HEAD" "^${upstream}" | sed '/^$/d' | sort -u | sed 's/^/  /'
}

main() {
  local anon_email="$DEFAULT_ANON_EMAIL"
  local anon_name=""
  local explicit_upstream=""
  local allow_dirty=0
  local create_backup=1
  local execute=0
  local filter_script=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --email)
        [[ $# -ge 2 ]] || die "--email requires a value"
        anon_email="$2"
        shift 2
        ;;
      --name)
        [[ $# -ge 2 ]] || die "--name requires a value"
        anon_name="$2"
        shift 2
        ;;
      --upstream)
        [[ $# -ge 2 ]] || die "--upstream requires a value"
        explicit_upstream="$2"
        shift 2
        ;;
      --allow-dirty)
        allow_dirty=1
        shift
        ;;
      --no-backup)
        create_backup=0
        shift
        ;;
      --execute)
        execute=1
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        die "unknown argument: $1"
        ;;
    esac
  done

  require_git_repo

  local current_branch
  current_branch="$(ensure_not_detached)"

  if [[ "$allow_dirty" -ne 1 ]]; then
    ensure_clean_worktree
  fi

  local upstream
  upstream="$(resolve_upstream "$explicit_upstream")"

  local commit_count
  commit_count="$(list_target_commits "$upstream" | wc -l | tr -d ' ')"
  [[ "$commit_count" -gt 0 ]] || die "no unpushed commits found relative to '$upstream'"

  print_summary "$upstream" "$anon_email" "$anon_name"

  if [[ "$execute" -ne 1 ]]; then
    echo
    echo "Dry run only. Re-run with --execute to rewrite these commits."
    exit 0
  fi

  local backup_branch=""
  if [[ "$create_backup" -eq 1 ]]; then
    backup_branch="backup/anonymize-emails-$(date +%Y%m%d-%H%M%S)"
    git branch "$backup_branch"
    echo
    echo "Created backup branch: $backup_branch"
  fi

  filter_script="$(mktemp)"
  trap '[[ -n "$filter_script" ]] && rm -f "$filter_script"' EXIT

  cat >"$filter_script" <<EOF
GIT_AUTHOR_EMAIL='$anon_email'
GIT_COMMITTER_EMAIL='$anon_email'
export GIT_AUTHOR_EMAIL GIT_COMMITTER_EMAIL
EOF

  if [[ -n "$anon_name" ]]; then
    cat >>"$filter_script" <<EOF
GIT_AUTHOR_NAME='$anon_name'
GIT_COMMITTER_NAME='$anon_name'
export GIT_AUTHOR_NAME GIT_COMMITTER_NAME
EOF
  fi

  FILTER_BRANCH_SQUELCH_WARNING=1 \
    git filter-branch -f --env-filter ". '$filter_script'" -- "$current_branch" "^${upstream}"

  echo
  echo "Rewrite complete."
  echo "Review with:"
  echo "  git log --format='%h %an <%ae> | %cn <%ce> | %s' ${upstream}..HEAD"
  if [[ -n "$backup_branch" ]]; then
    echo "Backup branch:"
    echo "  $backup_branch"
  fi
  echo
  echo "If the branch was already pushed elsewhere, force-push carefully:"
  echo "  git push --force-with-lease"
}

main "$@"
