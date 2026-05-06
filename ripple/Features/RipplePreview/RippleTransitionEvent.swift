import CoreGraphics
import Foundation

struct RippleTransitionEvent: Equatable {
    let id: Int
    let origin: CGPoint
    let fromImageIndex: Int
    let toImageIndex: Int
    let duration: TimeInterval
}
