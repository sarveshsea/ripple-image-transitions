# Read-only memi design-audit baseline

- Date: 2026-07-26
- Repository: `sarveshsea/ripple-image-transitions`
- Upstream: `eujinco/ripple-image-transitions`
- CLI: `@memi-design/cli@2.6.2`
- Action source: `sarveshsea/memi@ee3f3f00731a7a08c7616d4dfb14440165a86354`

## Method

The baseline was collected without allowing memi to write project files:

```bash
DO_NOT_TRACK=1 MEMI_TELEMETRY_DISABLED=1 \
  npx -y @memi-design/cli@2.6.2 \
  diagnose . --json --no-write --fail-on none
```

CI uses the same exact CLI version through a full-commit action pin. Generated
CI reports exist only in the runner workspace and uploaded artifact.

## Simulator evidence

The unchanged SwiftUI and Metal implementation plus replacement assets built
and launched successfully in Debug configuration on the `Nate Design QA 26.5`
iPhone simulator:

- XcodeBuildMCP build-and-run status: succeeded
- XcodeBuildMCP structured diagnostics: 0 warnings and 0 errors
- independent generic `xcodebuild`: succeeded, with one
  `appintentsmetadataprocessor` warning that metadata extraction was skipped
  because the app has no `AppIntents.framework` dependency
- bundle identifier: `com.example.ripple`
- visual evidence: [`media/memi-simulator-proof.jpg`](./media/memi-simulator-proof.jpg)

The simulator UI hierarchy could not be extracted by the automation tool.
Accordingly, the screenshot proves launch and rendering only; it does not clear
the accessibility or interaction findings below.

## Result and coverage

| Evidence | Result |
| --- | --- |
| Exit status | Passed with `fail-on none` |
| Reported score | 98, nominal only |
| Scanned files | 0 |
| Routes/components/styles | 0 / 0 / 0 |
| High-severity finding | `scan.empty`: no Tailwind or HTML class usage |
| Valid SwiftUI quality conclusion | None |

The reported 98 is not accepted as evidence of design quality. The scanner
assessed no Swift files and several UX dimensions were marked protected despite
having no rendered or behavioral evidence. This baseline therefore proves only
that the read-only integration runs; it also identifies SwiftUI coverage as the
primary Memi product gap.

## Manual SwiftUI and Metal review

Manual findings are kept separate from the Memi score:

1. **High: no reduced-motion path.** The tap always drives keyframe and shader
   animation. The sample should use `accessibilityReduceMotion` to provide an
   immediate or low-motion reveal.
2. **Medium: the image canvas is gesture-only.** `onSpatialTap` has no explicit
   accessibility action, label, or hint for assistive technologies.
3. **Medium: performance is reasoned about but not measured.** The shader caps
   sample offset and pre-decodes images, but there is no named-device frame-time
   or hitch evidence.
4. **Pass: shader math guards zero-distance, speed, amplitude, duration, and
   feather denominators.**
5. **Pass: transition ownership is bounded.** The preview model owns the atomic
   transition and ignores re-entry until completion.

These findings are observations for evaluation, not changes to the upstream
sample.

## Licensing evidence

The upstream MIT license and Eujin Nam copyright notice are preserved. The
three Apple-derived media files excluded by upstream were removed or replaced
before publication. Replacement provenance is documented in
[`media-rights.md`](./media-rights.md) and the machine-readable
[`media/provenance.json`](./media/provenance.json).

## Next acceptance gate

Memi should not claim SwiftUI audit support until it can:

- discover SwiftUI view, control, gesture, and shader source files
- report assessed and unassessed dimensions explicitly
- cite file and line evidence
- incorporate rendered simulator and reduced-motion evidence
- avoid producing a high aggregate score when scanner coverage is zero
