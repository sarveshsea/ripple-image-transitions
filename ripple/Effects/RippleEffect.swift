import SwiftUI

/// A modifier that performs a ripple effect whenever its trigger changes.
struct RippleEffect<T: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    var origin: CGPoint
    var trigger: T
    var tuning: RippleDefaults

    init(
        at origin: CGPoint,
        trigger: T,
        tuning: RippleDefaults = .standard
    ) {
        self.origin = origin
        self.trigger = trigger
        self.tuning = tuning
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if accessibilityReduceMotion {
            content
        } else {
            animatedContent(content)
        }
    }

    private func animatedContent(_ content: Content) -> some View {
        let snapshot = tuning

        return content.keyframeAnimator(
            initialValue: 0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(
                RippleModifier(
                    origin: origin,
                    elapsedTime: elapsedTime,
                    duration: snapshot.duration,
                    amplitude: snapshot.amplitude,
                    frequency: snapshot.frequency,
                    decay: snapshot.decay,
                    speed: snapshot.speed
                )
            )
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(snapshot.duration, duration: snapshot.duration)
        }
    }
}
