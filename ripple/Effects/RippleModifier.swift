import SwiftUI

/// A modifier that applies the ripple shader to its content.
struct RippleModifier: ViewModifier {
    private enum SamplingCostPolicy {
        // Keep the UI range expressive, but compress the expensive upper tail before it
        // reaches layerEffect sampling. `48` preserves the stronger ripple look while
        // avoiding the worst-case cost of the raw `80` slider ceiling. `0.35` keeps the
        // overflow responsive without letting sample offset growth stay linear.
        static let softAmplitudeCeiling: Double = 48
        static let overflowCompressionFactor: Double = 0.35
    }

    var origin: CGPoint
    var elapsedTime: TimeInterval
    var duration: TimeInterval
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double

    func body(content: Content) -> some View {
        let effectiveAmplitude = effectiveAmplitude
        let shader = ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsedTime),
            .float(effectiveAmplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )
        let maxSampleOffset = maxSampleOffset
        let elapsedTime = elapsedTime
        let duration = duration

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }

    private var maxSampleOffset: CGSize {
        CGSize(width: effectiveAmplitude, height: effectiveAmplitude)
    }

    private var effectiveAmplitude: Double {
        let safeAmplitude = max(amplitude, 0)
        let softCap = SamplingCostPolicy.softAmplitudeCeiling

        guard safeAmplitude > softCap else {
            return safeAmplitude
        }

        let overflow = safeAmplitude - softCap
        return softCap + (overflow * SamplingCostPolicy.overflowCompressionFactor)
    }
}
