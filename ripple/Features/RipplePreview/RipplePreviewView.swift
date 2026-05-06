import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct RipplePreviewView: View {
    private enum Assets {
        static let imageNames = ["palm_tree", "image_2"]
        // Cap oversized assets for this demo so the card stays sharp without paying the
        // full cost of arbitrarily large source textures during ripple and reveal passes.
        static let maxPreparedPixelSize: CGFloat = 2400

        #if canImport(UIKit)
        static let imageProvider = PreparedImageProvider(
            assetNames: imageNames,
            maxPixelSize: maxPreparedPixelSize
        )
        #endif
    }

    @State private var model = RipplePreviewModel()

    var body: some View {
        @Bindable var bindableModel = model

        VStack(spacing: 32) {
            RippleCanvasView(
                eventSnapshot: canvasEventSnapshot,
                tuningSnapshot: canvasTuningSnapshot,
                onTap: handleTap
            )
            .task(id: model.transitionTrigger) {
                await model.commitTransitionIfNeeded(for: model.transitionTrigger)
            }

            RippleControlsPanel(
                rippleStrength: $bindableModel.rippleStrength,
                waveDensity: $bindableModel.waveDensity,
                transitionDuration: $bindableModel.transitionDuration,
                revealSoftness: $bindableModel.revealSoftness
            )
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .fontDesign(.rounded)
    }

    private var canvasEventSnapshot: RippleCanvasEventSnapshot {
        let currentImage = Self.resolvedImage(at: model.currentImageIndex)
        let nextImage: Image? = model.isTransitioning
            ? model.latestTransitionEvent.map { Self.resolvedImage(at: $0.toImageIndex) }
            : nil

        return RippleCanvasEventSnapshot(
            currentImage: currentImage,
            nextImage: nextImage,
            transitionOrigin: model.transitionOrigin,
            transitionTrigger: model.transitionTrigger,
            transitionDuration: model.transitionDurationForCurrentEvent,
            rippleOrigin: model.rippleOrigin,
            rippleTrigger: model.rippleTrigger
        )
    }

    private var canvasTuningSnapshot: RippleCanvasTuningSnapshot {
        RippleCanvasTuningSnapshot(
            transitionFeather: model.transitionTuning.feather,
            rippleTuning: model.rippleTuning
        )
    }

    private static func resolvedImage(at index: Int) -> Image {
        #if canImport(UIKit)
        Image(uiImage: Assets.imageProvider.image(at: index))
        #else
        Image(Assets.imageNames[index])
        #endif
    }

    private func handleTap(_ point: CGPoint) {
        model.registerTap(at: point, imageCount: Assets.imageNames.count)
    }
}
