#!/usr/bin/env bash
set -euo pipefail

target="${1:-.}"
cd "$target"

git diff --exit-code HEAD -- .

allowed_generated_paths=(
  ".memoire/app-quality/design-health-badge.svg"
  ".memoire/app-quality/design-health.html"
  ".memoire/app-quality/design-health.md"
  ".memoire/app-quality/diagnosis.json"
  ".memoire/app-quality/diagnosis.md"
  ".memoire/app-quality/history.jsonl"
  ".memoire/app-quality/memi-results.sarif"
)

is_allowed_generated_path() {
  local candidate="$1"

  for allowed_path in "${allowed_generated_paths[@]}"; do
    if [[ "$candidate" == "$allowed_path" ]]; then
      return 0
    fi
  done

  return 1
}

unexpected_paths=()
while IFS= read -r candidate; do
  [[ -z "$candidate" ]] && continue
  if ! is_allowed_generated_path "$candidate"; then
    unexpected_paths+=("$candidate")
  fi
done < <(
  {
    git ls-files --others --exclude-standard
    git ls-files --others --ignored --exclude-standard
  } | sort -u
)

if (( ${#unexpected_paths[@]} > 0 )); then
  printf 'Unexpected repo-local files created by the audit:\n' >&2
  printf '  %s\n' "${unexpected_paths[@]}" >&2
  exit 1
fi

printf 'Read-only worktree verified; only declared Memi report artifacts are present.\n'
