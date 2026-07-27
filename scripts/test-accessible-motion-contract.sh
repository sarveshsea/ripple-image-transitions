#!/usr/bin/env bash
set -euo pipefail

preview_view="ripple/Features/RipplePreview/RipplePreviewView.swift"
canvas_view="ripple/Features/RipplePreview/RippleCanvasView.swift"
effect="ripple/Effects/RippleEffect.swift"
model="ripple/Features/RipplePreview/RipplePreviewModel.swift"

require_pattern() {
  local pattern="$1"
  local path="$2"
  local message="$3"

  grep -Eq "$pattern" "$path" || {
    printf '%s\n' "$message" >&2
    exit 1
  }
}

require_pattern \
  '@Environment\(\\\.accessibilityReduceMotion\)' \
  "$preview_view" \
  'RipplePreviewView must read the system Reduce Motion preference.'

require_pattern \
  '@Environment\(\\\.accessibilityReduceMotion\)' \
  "$canvas_view" \
  'RippleCanvasView must gate its animator from the local Reduce Motion environment.'

require_pattern \
  '@Environment\(\\\.accessibilityReduceMotion\)' \
  "$effect" \
  'RippleEffect must gate its shader animator from the local Reduce Motion environment.'

require_pattern \
  'if[[:space:]]+accessibilityReduceMotion' \
  "$effect" \
  'RippleEffect must bypass its keyframe animator when Reduce Motion is enabled.'

require_pattern \
  'registerTap\(at.*imageCount:.*reduceMotion:' \
  "$model" \
  'RipplePreviewModel must accept the Reduce Motion state when registering a transition.'

require_pattern \
  'reduceMotion[[:space:]]*\?[[:space:]]*0[[:space:]]*:' \
  "$model" \
  'Reduced-motion transitions must use zero duration.'

require_pattern \
  'reduceMotion[[:space:]]*\?[[:space:]]*0[[:space:]]*:[[:space:]]*model\.rippleTrigger' \
  "$preview_view" \
  'Reduced Motion must suppress the ripple shader trigger.'

require_pattern \
  '\.accessibilityLabel\(' \
  "$canvas_view" \
  'The image canvas must provide an accessibility label.'

require_pattern \
  '\.accessibilityValue\(' \
  "$canvas_view" \
  'The image canvas must expose the current image as an accessibility value.'

require_pattern \
  '\.accessibilityHint\(' \
  "$canvas_view" \
  'The image canvas must explain its default accessibility action.'

require_pattern \
  '\.accessibilityAction[[:space:]]*\{' \
  "$canvas_view" \
  'The image canvas must provide a default accessibility action.'

printf 'Accessible motion contract verified.\n'
