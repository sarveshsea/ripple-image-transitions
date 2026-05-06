import SwiftUI

struct RipplePreviewScreen: View {
    private enum LayoutMetrics {
        static let outerPadding: CGFloat = 20
        static let maxContentWidth: CGFloat = 1100
    }

    var body: some View {
        RipplePreviewView()
            .frame(maxWidth: LayoutMetrics.maxContentWidth, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, LayoutMetrics.outerPadding)
            .padding(.vertical, 24)
            .background(
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            )
    }
}
