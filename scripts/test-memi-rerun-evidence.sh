#!/usr/bin/env bash
set -euo pipefail

evidence_path="docs/memi-rerun-evidence.json"

node --input-type=module - "$evidence_path" <<'NODE'
import fs from "node:fs";

const evidencePath = process.argv[2];
const evidence = JSON.parse(fs.readFileSync(evidencePath, "utf8"));

const assert = (condition, message) => {
  if (!condition) {
    throw new Error(message);
  }
};

assert(evidence.schemaVersion === 1, "Unexpected rerun evidence schema.");
assert(
  evidence.memiCandidate.reproduction.matchesRecordedDigest === true
    && evidence.memiCandidate.reproduction.distIndexSha256 === evidence.memiCandidate.distIndexSha256,
  "The Memi candidate build reproduction must match the recorded executable digest.",
);
assert(evidence.before.worktreeCleanBeforeAndAfter === true, "Before worktree must be clean.");
assert(evidence.after.worktreeCleanBeforeAndAfter === true, "After worktree must be clean.");
assert(evidence.before.scannedFiles === evidence.after.scannedFiles, "Scan scope changed across the rerun.");
assert(evidence.before.issues.length === 2, "Before evidence must retain both findings.");
assert(evidence.after.issues.length === 0, "After evidence must have zero assessed findings.");
assert(evidence.after.gatingIssues === 0, "After evidence must have zero gating issues.");
assert(evidence.after.score === 0, "Partial native coverage must not receive an aggregate score.");
assert(
  evidence.after.unassessedDimensions.includes("metal:gpu-performance"),
  "GPU performance must remain explicitly unassessed.",
);
assert(
  evidence.after.appliedScoreCaps.some(
    (cap) => cap.id === "partial-source-analysis" && cap.maximum === 0,
  ),
  "The partial-source score cap must remain recorded.",
);
assert(
  evidence.simulator.runtimeAccessibility.beforeAction.endsWith("Image 1 of 2")
    && evidence.simulator.runtimeAccessibility.afterAction.endsWith("Image 2 of 2"),
  "Runtime accessibility state transition is incomplete.",
);
assert(
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/.test(
    evidence.simulator.latestVerification.verifiedAt,
  ),
  "Fresh simulator verification must retain a UTC timestamp.",
);
assert(
  /^[0-9a-f]{40}$/.test(evidence.simulator.latestVerification.forkCommit),
  "Fresh simulator verification must bind to an exact fork commit.",
);
assert(
  evidence.simulator.latestVerification.systemReduceMotionEnabled === false,
  "Fresh verification scope must not imply the reduced-motion setting was enabled.",
);
assert(
  evidence.simulator.latestVerification.buildRun.status === "succeeded"
    && evidence.simulator.latestVerification.buildRun.warnings === 0
    && evidence.simulator.latestVerification.buildRun.errors === 0,
  "Fresh simulator build result is incomplete.",
);
assert(
  evidence.simulator.latestVerification.runtimeAccessibility.beforeAction.endsWith("Image 1 of 2")
    && evidence.simulator.latestVerification.runtimeAccessibility.afterAction.endsWith("Image 2 of 2"),
  "Fresh runtime accessibility state transition is incomplete.",
);
assert(
  /^[0-9a-f]{40}$/.test(evidence.simulator.buildInputs.rippleTree),
  "Simulator evidence must bind to the audited ripple source tree.",
);
assert(
  /^[0-9a-f]{40}$/.test(evidence.simulator.buildInputs.projectFileBlob),
  "Simulator evidence must bind to the audited Xcode project file.",
);
NODE

hash_file() {
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
  else
    shasum -a 256 "$path" | awk '{print $1}'
  fi
}

for path in \
  docs/media/memi-reduced-motion-before.jpg \
  docs/media/memi-reduced-motion-after.jpg
do
  expected_hash="$(node -e '
    const fs = require("node:fs");
    const evidence = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const artifact = evidence.artifacts.find((entry) => entry.path === process.argv[2]);
    if (!artifact) process.exit(2);
    process.stdout.write(artifact.sha256);
  ' "$evidence_path" "$path")"
  actual_hash="$(hash_file "$path")"
  test "$actual_hash" = "$expected_hash" || {
    printf 'Evidence hash mismatch for %s.\n' "$path" >&2
    exit 1
  }
done

read_commit() {
  local field="$1"
  node -e '
  const fs = require("node:fs");
  const evidence = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  process.stdout.write(evidence[process.argv[2]].forkCommit);
' "$evidence_path" "$field"
}

before_commit="$(read_commit before)"
after_commit="$(read_commit after)"
latest_verification_commit="$(
  node -e '
    const fs = require("node:fs");
    const evidence = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    process.stdout.write(evidence.simulator.latestVerification.forkCommit);
  ' "$evidence_path"
)"

git cat-file -e "${before_commit}^{commit}"
git cat-file -e "${after_commit}^{commit}"
git cat-file -e "${latest_verification_commit}^{commit}"
git merge-base --is-ancestor "$before_commit" "$after_commit"
git merge-base --is-ancestor "$after_commit" HEAD
git merge-base --is-ancestor "$latest_verification_commit" HEAD

expected_ripple_tree="$(
  node -e '
    const fs = require("node:fs");
    const evidence = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    process.stdout.write(evidence.simulator.buildInputs.rippleTree);
  ' "$evidence_path"
)"
expected_project_blob="$(
  node -e '
    const fs = require("node:fs");
    const evidence = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    process.stdout.write(evidence.simulator.buildInputs.projectFileBlob);
  ' "$evidence_path"
)"

test "$(git rev-parse HEAD:ripple)" = "$expected_ripple_tree"
test "$(git rev-parse HEAD:ripple.xcodeproj/project.pbxproj)" = "$expected_project_blob"
test "$(git rev-parse "$latest_verification_commit:ripple")" = "$expected_ripple_tree"
test "$(git rev-parse "$latest_verification_commit:ripple.xcodeproj/project.pbxproj")" = "$expected_project_blob"

printf 'Memi SwiftUI rerun evidence verified.\n'
