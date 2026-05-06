# Project Structure

## Top Level

```text
.
├── README.md
├── docs/
├── LICENSE
├── ripple.xcodeproj
└── ripple/
```

## App Source

```text
ripple/
├── rippleApp.swift
├── Ripple.metal
├── TransitionReveal.metal
├── Assets.xcassets/
├── Effects/
├── Gestures/
└── Features/
    └── RipplePreview/
```

## Responsibility Split

- `RipplePreviewScreen` handles outer layout and background styling
- `RipplePreviewView` owns the model and derives render snapshots
- `RipplePreviewModel` owns transition truth and commit policy
- `RippleCanvasView` renders from snapshots and callbacks
- `RippleControlsPanel` exposes the four tuning controls

## Why It Stays Small

This sample avoids extra layers, package splits, and generalized abstractions so the interaction stays easy to inspect.
