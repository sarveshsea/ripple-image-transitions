#!/usr/bin/env bash
set -euo pipefail

workflow=".github/workflows/memi-design-audit.yml"

grep -Eq '^[[:space:]]+fetch-depth:[[:space:]]+0([[:space:]]|$)' "$workflow" || {
  printf 'Memi audit checkout must fetch full history so origin/main can be resolved.\n' >&2
  exit 1
}

grep -Eq 'uses:[[:space:]]+actions/checkout@[0-9a-f]{40}([[:space:]]|$)' "$workflow" || {
  printf 'Checkout must remain pinned to an immutable commit.\n' >&2
  exit 1
}

grep -Eq '^[[:space:]]+contents:[[:space:]]+read([[:space:]]|$)' "$workflow" || {
  printf 'Memi audit must retain read-only repository permissions.\n' >&2
  exit 1
}

grep -Eq '^[[:space:]]+persist-credentials:[[:space:]]+false([[:space:]]|$)' "$workflow" || {
  printf 'Checkout credentials must not persist in the Memi audit workspace.\n' >&2
  exit 1
}

grep -Eq 'uses:[[:space:]]+sarveshsea/memi@[0-9a-f]{40}([[:space:]]|$)' "$workflow" || {
  printf 'The Memi action must remain pinned to an immutable commit.\n' >&2
  exit 1
}

grep -Eq '^[[:space:]]+version:[[:space:]]+"[0-9]+\.[0-9]+\.[0-9]+"([[:space:]]|$)' "$workflow" || {
  printf 'The Memi CLI must remain pinned to an exact version.\n' >&2
  exit 1
}

grep -Fq 'bash scripts/verify-read-only-worktree.sh' "$workflow" || {
  printf 'The hosted workflow must prove that Memi left no undeclared repo-local changes.\n' >&2
  exit 1
}

grep -Eq '^[[:space:]]+if:[[:space:]]+\$\{\{[[:space:]]*always\(\)[[:space:]]*\}\}([[:space:]]|$)' "$workflow" || {
  printf 'The mutation proof must run even if the Memi action fails.\n' >&2
  exit 1
}

git rev-parse --verify --quiet origin/main >/dev/null || {
  printf 'Memi audit checkout must expose origin/main.\n' >&2
  exit 1
}

git merge-base HEAD origin/main >/dev/null || {
  printf 'Memi audit checkout must have enough history to resolve the origin/main merge base.\n' >&2
  exit 1
}

printf 'Memi workflow history and read-only contract verified.\n'
