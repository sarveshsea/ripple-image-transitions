#!/usr/bin/env bash
set -euo pipefail

provenance_path="docs/media/provenance.json"

forbidden_paths=(
  "docs/media/github-cover.jpg"
  "ripple/Assets.xcassets/image_2.imageset/image-2.jpg"
)

denied_hashes=(
  "878dc73ac54772edf6f11875dc33d0e3e4890eff36df226dde048f0e7112244f"
  "0eaad28660474f180617af4ca26e2933f235752a0422e6405326af9b815fdf17"
  "81c7ccdef20ecb065f4daf442e8e65c3d1da3641c6311b30338a90ea258b872b"
)

if [[ -n "${MEDIA_PROVENANCE_TEST_DENIED_HASH:-}" ]]; then
  denied_hashes+=("$MEDIA_PROVENANCE_TEST_DENIED_HASH")
fi

replacement_paths=(
  "ripple/Assets.xcassets/palm_tree.imageset/image.png"
  "ripple/Assets.xcassets/image_2.imageset/image-2.png"
  "docs/media/memi-simulator-proof.jpg"
)

replacement_hashes=(
  "1bf16370ba93a85f83f42636d12001d916b02a269c87d2dc27e05b852416d1b1"
  "693ce5ff5f685b6c38868dc63a7b1a30c14252dd54ceb626b32a790fc0837692"
  "6978232a450b958ca039c54ba10a1675017d3840cc84bcefd60de3d63ab8a6a4"
)

hash_file() {
  local path="$1"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
  else
    shasum -a 256 "$path" | awk '{print $1}'
  fi
}

test -s "$provenance_path"

if command -v node >/dev/null 2>&1; then
  node -e 'JSON.parse(require("node:fs").readFileSync(process.argv[1], "utf8"))' "$provenance_path"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool "$provenance_path" >/dev/null
else
  printf 'Node.js or Python 3 is required to validate media provenance JSON.\n' >&2
  exit 1
fi

for path in "${forbidden_paths[@]}"; do
  if [[ -e "$path" ]]; then
    printf 'Excluded upstream media path is present: %s\n' "$path" >&2
    exit 1
  fi
done

check_denied_hash() {
  local path="$1"
  local actual_hash

  actual_hash="$(hash_file "$path")"

  for denied_hash in "${denied_hashes[@]}"; do
    if [[ "$actual_hash" == "$denied_hash" ]]; then
      printf 'Excluded upstream media hash found at %s: %s\n' "$path" "$actual_hash" >&2
      exit 1
    fi
  done
}

while IFS= read -r -d '' path; do
  check_denied_hash "$path"
done < <(git ls-files -z)

if [[ -n "${MEDIA_PROVENANCE_TEST_PATH:-}" ]]; then
  test -f "$MEDIA_PROVENANCE_TEST_PATH"
  check_denied_hash "$MEDIA_PROVENANCE_TEST_PATH"
fi

for index in "${!replacement_paths[@]}"; do
  path="${replacement_paths[$index]}"
  expected_hash="${replacement_hashes[$index]}"

  test -s "$path"
  actual_hash="$(hash_file "$path")"

  if [[ "$actual_hash" != "$expected_hash" ]]; then
    printf 'Replacement media hash mismatch for %s: expected %s, received %s\n' \
      "$path" "$expected_hash" "$actual_hash" >&2
    exit 1
  fi

  grep -Fq "\"path\": \"$path\"" "$provenance_path"
  grep -Fq "\"sha256\": \"$expected_hash\"" "$provenance_path"
done

for denied_hash in "${denied_hashes[@]}"; do
  grep -Fq "\"sha256\": \"$denied_hash\"" "$provenance_path"
done

grep -Fq '"tool": "OpenAI Codex image_gen.imagegen"' "$provenance_path"
grep -Fq '"prompt":' "$provenance_path"
grep -Fq '"licenseBasis":' "$provenance_path"
grep -Fq 'https://openai.com/policies/terms-of-use/' "$provenance_path"
grep -Fq 'https://openai.com/policies/services-agreement/' "$provenance_path"

printf 'Media provenance verified: 3 denied hashes absent, 3 replacement hashes matched.\n'
