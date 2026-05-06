struct RipplePreviewTuningSpec {
    struct DoubleField {
        let defaultValue: Double
        let displayRange: ClosedRange<Double>
        let sanitizeRange: ClosedRange<Double>
        let step: Double
    }

    // Keep display and sanitize ranges explicit even when they currently match.
    static let amplitude = DoubleField(
        defaultValue: RippleDefaults.standard.amplitude,
        displayRange: 0.0...80.0,
        sanitizeRange: 0.0...80.0,
        step: 0.5
    )

    static let frequency = DoubleField(
        defaultValue: RippleDefaults.standard.frequency,
        displayRange: 1.0...30.0,
        sanitizeRange: 1.0...30.0,
        step: 0.5
    )

    static let duration = DoubleField(
        defaultValue: TransitionRevealTuning.standard.duration,
        displayRange: 0.1...2.0,
        sanitizeRange: 0.1...2.0,
        step: 0.01
    )

    static let feather = DoubleField(
        defaultValue: Double(TransitionRevealTuning.standard.feather),
        displayRange: 1.0...200.0,
        sanitizeRange: 1.0...200.0,
        step: 1.0
    )
}
