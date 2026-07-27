import CoreGraphics
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class RipplePreviewModel {
    // Owns feature state and transition orchestration.
    var currentImageIndex = 0
    var latestTransitionEvent: RippleTransitionEvent?
    var rippleStrength = RipplePreviewTuningSpec.amplitude.defaultValue
    var waveDensity = RipplePreviewTuningSpec.frequency.defaultValue
    var transitionDuration = RipplePreviewTuningSpec.duration.defaultValue
    var revealSoftness = RipplePreviewTuningSpec.feather.defaultValue

    var rippleTuning: RippleDefaults {
        let standard = RippleDefaults.standard

        return RippleDefaults(
            duration: standard.duration,
            amplitude: sanitized(
                rippleStrength,
                fallback: RipplePreviewTuningSpec.amplitude.defaultValue,
                range: RipplePreviewTuningSpec.amplitude.sanitizeRange
            ),
            frequency: sanitized(
                waveDensity,
                fallback: RipplePreviewTuningSpec.frequency.defaultValue,
                range: RipplePreviewTuningSpec.frequency.sanitizeRange
            ),
            decay: standard.decay,
            speed: standard.speed
        )
    }

    var transitionTuning: TransitionRevealTuning {
        TransitionRevealTuning(
            duration: sanitized(
                transitionDuration,
                fallback: RipplePreviewTuningSpec.duration.defaultValue,
                range: RipplePreviewTuningSpec.duration.sanitizeRange
            ),
            feather: CGFloat(
                sanitized(
                    revealSoftness,
                    fallback: RipplePreviewTuningSpec.feather.defaultValue,
                    range: RipplePreviewTuningSpec.feather.sanitizeRange
                )
            )
        )
    }

    var isTransitioning: Bool {
        guard let latestTransitionEvent else { return false }
        return currentImageIndex == latestTransitionEvent.fromImageIndex
            && currentImageIndex != latestTransitionEvent.toImageIndex
    }

    var rippleOrigin: CGPoint {
        latestTransitionEvent?.origin ?? .zero
    }

    var rippleTrigger: Int {
        latestTransitionEvent?.id ?? 0
    }

    var transitionOrigin: CGPoint {
        isTransitioning ? rippleOrigin : .zero
    }

    var transitionTrigger: Int {
        isTransitioning ? rippleTrigger : 0
    }

    var transitionDurationForCurrentEvent: TimeInterval {
        isTransitioning ? (latestTransitionEvent?.duration ?? 0) : 0
    }

    func registerTap(at point: CGPoint, imageCount: Int, reduceMotion: Bool) {
        guard !isTransitioning, imageCount > 0 else { return }

        let nextEventID = (latestTransitionEvent?.id ?? 0) + 1
        let fromImageIndex = currentImageIndex
        let nextImageIndex = (currentImageIndex + 1) % imageCount
        let transitionDuration = reduceMotion ? 0 : transitionTuning.duration

        latestTransitionEvent = RippleTransitionEvent(
            id: nextEventID,
            origin: point,
            fromImageIndex: fromImageIndex,
            toImageIndex: nextImageIndex,
            duration: transitionDuration
        )
    }

    func commitTransitionIfNeeded(for eventID: Int) async {
        guard
            eventID > 0,
            let transitionEvent = latestTransitionEvent,
            transitionEvent.id == eventID
        else {
            return
        }

        let clampedDuration = max(transitionEvent.duration, 0)
        if clampedDuration > 0 {
            let sleepNanoseconds = UInt64(clampedDuration * 1_000_000_000)
            do {
                try await Task.sleep(nanoseconds: sleepNanoseconds)
            } catch {
                return
            }
        }

        guard !Task.isCancelled else {
            return
        }

        guard
            let latestTransitionEvent,
            latestTransitionEvent.id == eventID,
            currentImageIndex == latestTransitionEvent.fromImageIndex
        else {
            return
        }

        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            currentImageIndex = latestTransitionEvent.toImageIndex
        }
    }

    private func sanitized(
        _ value: Double,
        fallback: Double,
        range: ClosedRange<Double>
    ) -> Double {
        let finiteValue = value.isFinite ? value : fallback
        return min(max(finiteValue, range.lowerBound), range.upperBound)
    }
}
