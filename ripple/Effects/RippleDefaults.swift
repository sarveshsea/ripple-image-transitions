import Foundation

struct RippleDefaults: Sendable {
    let duration: TimeInterval
    let amplitude: Double
    let frequency: Double
    let decay: Double
    let speed: Double

    nonisolated static let standard = RippleDefaults(
        duration: 2.0,
        amplitude: 25,
        frequency: 20,
        decay: 3.5,
        speed: 1200
    )
}
