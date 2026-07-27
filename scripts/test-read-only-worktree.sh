#!/usr/bin/env bash
set -euo pipefail

repo_root="$(pwd)"
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/memi-read-only-worktree.XXXXXX")"
output_path="$(mktemp "${TMPDIR:-/tmp}/memi-read-only-output.XXXXXX")"

cleanup() {
  rm -rf "$fixture_root"
  rm -f "$output_path"
}
trap cleanup EXIT

git -C "$fixture_root" init --quiet
git -C "$fixture_root" config user.email "ci@example.invalid"
git -C "$fixture_root" config user.name "Memi CI"

printf '.memoire/\n' > "$fixture_root/.gitignore"
printf 'tracked\n' > "$fixture_root/tracked.txt"
git -C "$fixture_root" add .gitignore tracked.txt
git -C "$fixture_root" commit --quiet -m "test fixture"

mkdir -p "$fixture_root/.memoire/app-quality"
printf '{}\n' > "$fixture_root/.memoire/app-quality/diagnosis.json"
bash "$repo_root/scripts/verify-read-only-worktree.sh" "$fixture_root"

printf 'unexpected\n' > "$fixture_root/.memoire/unexpected.txt"
if bash "$repo_root/scripts/verify-read-only-worktree.sh" "$fixture_root" >"$output_path" 2>&1; then
  printf 'Expected an undeclared ignored artifact to fail read-only verification.\n' >&2
  exit 1
fi
grep -Fq '.memoire/unexpected.txt' "$output_path"

rm -f "$fixture_root/.memoire/unexpected.txt"
printf 'changed\n' > "$fixture_root/tracked.txt"
if bash "$repo_root/scripts/verify-read-only-worktree.sh" "$fixture_root" >"$output_path" 2>&1; then
  printf 'Expected a tracked mutation to fail read-only verification.\n' >&2
  exit 1
fi

printf 'Read-only worktree regression tests passed.\n'
