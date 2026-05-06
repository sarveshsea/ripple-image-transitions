# Architecture

## Core Rule

The sample is built around one atomic transition event.

Each tap defines:

- the ripple origin
- the reveal origin
- the current image index
- the next image index
- the transition duration
- the event id used to validate the final commit

## Main Pieces

### `RippleTransitionEvent`

- [RippleTransitionEvent.swift](../ripple/Features/RipplePreview/RippleTransitionEvent.swift)

This is the immutable event payload for one transition.

### `RipplePreviewModel`

- [RipplePreviewModel.swift](../ripple/Features/RipplePreview/RipplePreviewModel.swift)

This owns the feature state. It tracks the current image, stores the active event, owns the tuning values, and commits the next image only after the transition finishes.

### `RipplePreviewView`

- [RipplePreviewView.swift](../ripple/Features/RipplePreview/RipplePreviewView.swift)

This owns the model instance, wires up the controls, and turns model state into render snapshots.

### `RippleCanvasView`

- [RippleCanvasView.swift](../ripple/Features/RipplePreview/RippleCanvasView.swift)

This is the render boundary. It renders from snapshots and does not decide when image state should change.

### Effects And Shaders

- [RippleEffect.swift](../ripple/Effects/RippleEffect.swift)
- [RippleModifier.swift](../ripple/Effects/RippleModifier.swift)
- [TransitionRevealModifier.swift](../ripple/Effects/TransitionRevealModifier.swift)
- [Ripple.metal](../ripple/Ripple.metal)
- [TransitionReveal.metal](../ripple/TransitionReveal.metal)

The Swift modifiers wrap the shader entry points. The shader files implement the ripple and reveal effects.

## Data Flow

```text
tap
  -> model registers one event
  -> view derives snapshots
  -> canvas renders ripple + reveal
  -> model validates the event before committing the next image
```
