# Getting Started

## Requirements

- Xcode with the iOS `26.4` SDK
- the Metal toolchain installed in Xcode
- iOS Simulator or a physical iPhone/iPad target

## Run

1. Open `ripple.xcodeproj`.
2. Select the `ripple` scheme.
3. Choose an iOS Simulator or physical device.
4. Run the app.

If you run on a physical device:

- set your own Apple development team in Signing & Capabilities
- replace `com.example.ripple` with a bundle identifier that is unique to your account

## What To Expect

- the app launches directly into the ripple preview screen
- the card starts on the first image
- tapping the card starts both the ripple and the reveal from the same location
- the next image becomes current only after the reveal finishes
- the sliders control strength, density, transition duration, and reveal softness

## Good Files To Read First

- [RipplePreviewModel.swift](../ripple/Features/RipplePreview/RipplePreviewModel.swift)
- [RipplePreviewView.swift](../ripple/Features/RipplePreview/RipplePreviewView.swift)
- [RippleCanvasView.swift](../ripple/Features/RipplePreview/RippleCanvasView.swift)
- [RippleTransitionEvent.swift](../ripple/Features/RipplePreview/RippleTransitionEvent.swift)
