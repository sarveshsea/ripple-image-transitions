#!/usr/bin/env bash
set -euo pipefail

test -s LICENSE
grep -Fq 'Copyright (c) 2026 Eujin Nam' LICENSE
grep -Fq 'MIT License' LICENSE

test -s NOTICE.md
grep -Fq 'eujinco/ripple-image-transitions' NOTICE.md
grep -Fq 'not affiliated with or endorsed by' NOTICE.md
grep -Fq 'upstream' NOTICE.md
grep -Fq 'maintainer' NOTICE.md
grep -Fq 'same MIT terms' NOTICE.md
grep -Fq 'to the extent' NOTICE.md
grep -Fq 'fork maintainer holds rights' NOTICE.md

printf 'MIT attribution and fork boundary verified.\n'
