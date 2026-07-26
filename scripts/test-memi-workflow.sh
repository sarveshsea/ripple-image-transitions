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

git rev-parse --verify --quiet origin/main >/dev/null || {
  printf 'Memi audit checkout must expose origin/main.\n' >&2
  exit 1
}

git merge-base HEAD origin/main >/dev/null || {
  printf 'Memi audit checkout must have enough history to resolve the origin/main merge base.\n' >&2
  exit 1
}

printf 'Memi workflow history and read-only contract verified.\n'
