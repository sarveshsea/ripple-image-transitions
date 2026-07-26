#!/usr/bin/env bash
set -euo pipefail

fixture_path="$(mktemp "./.media-provenance-denylist.XXXXXX")"
output_path="$(mktemp "./.media-provenance-output.XXXXXX")"

cleanup() {
  rm -f "$fixture_path" "$output_path"
}
trap cleanup EXIT

printf 'harmless renamed-media denylist fixture\n' > "$fixture_path"

if command -v sha256sum >/dev/null 2>&1; then
  fixture_hash="$(sha256sum "$fixture_path" | awk '{print $1}')"
else
  fixture_hash="$(shasum -a 256 "$fixture_path" | awk '{print $1}')"
fi

if MEDIA_PROVENANCE_TEST_DENIED_HASH="$fixture_hash" \
  MEDIA_PROVENANCE_TEST_PATH="$fixture_path" \
  bash scripts/verify-media-provenance.sh >"$output_path" 2>&1; then
  printf 'Expected renamed-media denylist fixture to fail verification.\n' >&2
  exit 1
fi

grep -Fq "Excluded upstream media hash found at $fixture_path" "$output_path"

rm -f "$fixture_path" "$output_path"
trap - EXIT

bash scripts/verify-media-provenance.sh
printf 'Renamed-media denylist regression test passed.\n'
