import SwiftUI

struct RippleControlsPanel: View {
    @Binding var rippleStrength: Double
    @Binding var waveDensity: Double
    @Binding var transitionDuration: Double
    @Binding var revealSoftness: Double

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ControlRow(
                    title: "Strength",
                    value: $rippleStrength,
                    range: RipplePreviewTuningSpec.amplitude.displayRange,
                    step: RipplePreviewTuningSpec.amplitude.step
                )
                ControlRow(
                    title: "Density",
                    value: $waveDensity,
                    range: RipplePreviewTuningSpec.frequency.displayRange,
                    step: RipplePreviewTuningSpec.frequency.step
                )
            }

            HStack(spacing: 10) {
                ControlRow(
                    title: "Transition",
                    value: $transitionDuration,
                    range: RipplePreviewTuningSpec.duration.displayRange,
                    step: RipplePreviewTuningSpec.duration.step
                )
                ControlRow(
                    title: "Softness",
                    value: $revealSoftness,
                    range: RipplePreviewTuningSpec.feather.displayRange,
                    step: RipplePreviewTuningSpec.feather.step
                )
            }
        }
    }
}

private struct ControlRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        let fractionDigits = Self.fractionDigits(for: step)

        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 8)

                Text(value.formatted(.number.precision(.fractionLength(fractionDigits))))
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }

            Slider(value: $value, in: range, step: step)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private static func fractionDigits(for step: Double) -> Int {
        let normalizedStep = max(step, 0.000_001)
        let digits = Int(ceil(-log10(normalizedStep)))
        return max(0, digits)
    }
}
