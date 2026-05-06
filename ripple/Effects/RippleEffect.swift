import SwiftUI

/// A modifier that performs a ripple effect whenever its trigger changes.
struct RippleEffect<T: Equatable>: ViewModifier {
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

    func body(content: Content) -> some View {
        let duration = tuning.duration
        let amplitude = tuning.amplitude
        let frequency = tuning.frequency
        let decay = tuning.decay
        let speed = tuning.speed

        content.keyframeAnimator(
            initialValue: 0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(
                RippleModifier(
                    origin: origin,
                    elapsedTime: elapsedTime,
                    duration: duration,
                    amplitude: amplitude,
                    frequency: frequency,
                    decay: decay,
                    speed: speed
                )
            )
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}
