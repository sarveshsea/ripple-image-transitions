import SwiftUI

extension View {
    func onSpatialTap(_ action: @escaping (CGPoint) -> Void) -> some View {
        gesture(
            SpatialTapGesture()
                .onEnded { event in
                    action(event.location)
                }
        )
    }
}
