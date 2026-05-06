import SwiftUI

struct TransitionRevealTuning: Sendable {
    let duration: TimeInterval
    let feather: CGFloat

    nonisolated static let standard = TransitionRevealTuning(
        duration: 0.45,
        feather: 100
    )
}

struct TransitionRevealModifier: ViewModifier {
    private static let minimumFeather: CGFloat = 0.0001

    var origin: CGPoint
    var elapsedTime: TimeInterval
    var duration: TimeInterval
    var maxRadius: CGFloat
    var feather: CGFloat

    func body(content: Content) -> some View {
        let safeFeather = max(feather, Self.minimumFeather)
        let shader = ShaderLibrary.TransitionReveal(
            .float2(origin),
            .float(elapsedTime),
            .float(duration),
            .float(maxRadius),
            .float(safeFeather)
        )

        content.visualEffect { view, _ in
            view.colorEffect(shader, isEnabled: maxRadius > 0)
        }
    }

    static func maxRadius(
        for size: CGSize,
        origin: CGPoint,
        feather: CGFloat
    ) -> CGFloat {
        let safeFeather = max(feather, minimumFeather)
        let corners = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: size.width, y: 0),
            CGPoint(x: 0, y: size.height),
            CGPoint(x: size.width, y: size.height),
        ]

        let farthestDistance = corners
            .map { hypot($0.x - origin.x, $0.y - origin.y) }
            .max() ?? 0

        return farthestDistance + safeFeather
    }
}
