# Customization Notes

## Usually Safe

- replace the sample images if you update the asset catalog and `Assets.imageNames` together in [RipplePreviewView.swift](../ripple/Features/RipplePreview/RipplePreviewView.swift)
- adjust slider ranges or defaults in [RipplePreviewTuningSpec.swift](../ripple/Features/RipplePreview/RipplePreviewTuningSpec.swift)
- adjust ripple defaults in [RippleDefaults.swift](../ripple/Effects/RippleDefaults.swift)
- adjust reveal defaults in [TransitionRevealModifier.swift](../ripple/Effects/TransitionRevealModifier.swift)
- restyle the screen shell in [RipplePreviewScreen.swift](../ripple/Features/RipplePreview/RipplePreviewScreen.swift)
- restyle the controls in [RippleControlsPanel.swift](../ripple/Features/RipplePreview/RippleControlsPanel.swift)

## Image Asset Requirement

- image asset names must exactly match the names configured in `Assets.imageNames`
- when replacing the sample images, update the asset catalog and the configured names together
- if an asset name does not match, debug-oriented builds raise an assertion in [PreparedImageProvider.swift](../ripple/Features/RipplePreview/PreparedImageProvider.swift)
- non-debug runs fall back to the first successfully loaded sample image when one is available

## Easy Ways To Break The Sample

- removing the `!isTransitioning` guard from `registerTap`
- moving next-image selection into render code
- committing image state before the reveal duration completes
- splitting ripple ownership and reveal ownership across separate state owners

## If You Add More Images

1. update `Assets.imageNames`
2. keep the `imageCount` passed into `registerTap` in sync with the asset list
3. keep the rule that each event selects exactly one next image
