import SwiftUI

struct RippleCanvasEventSnapshot {
    let currentImage: Image
    let nextImage: Image?
    let transitionOrigin: CGPoint
    let transitionTrigger: Int
    let transitionDuration: TimeInterval
    let rippleOrigin: CGPoint
    let rippleTrigger: Int
}

struct RippleCanvasTuningSnapshot {
    let transitionFeather: CGFloat
    let rippleTuning: RippleDefaults
}

struct RippleCanvasView: View {
    private enum LayoutMetrics {
        static let cornerRadius: CGFloat = 28
        static let cardAspectRatio: CGFloat = 10.0 / 7.0
    }

    let eventSnapshot: RippleCanvasEventSnapshot
    let tuningSnapshot: RippleCanvasTuningSnapshot
    let reduceMotion: Bool
    let accessibilityValue: String
    let onTap: (CGPoint) -> Void
    @State private var canvasSize = CGSize.zero

    var body: some View {
        Color.clear
            .aspectRatio(LayoutMetrics.cardAspectRatio, contentMode: .fit)
            .overlay {
                GeometryReader { proxy in
                    transitionComposite(in: proxy.size)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius, style: .continuous))
            .frame(maxWidth: .infinity, alignment: .leading)
            .onSpatialTap(onTap)
            .modifier(
                RippleEffect(
                    at: eventSnapshot.rippleOrigin,
                    trigger: eventSnapshot.rippleTrigger,
                    tuning: tuningSnapshot.rippleTuning
                )
            )
            .shadow(color: .black.opacity(0.12), radius: 18, y: 10)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                canvasSize = newSize
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Ripple image preview")
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Double-tap to show the next image.")
            .accessibilityAction {
                onTap(accessibilityOrigin)
            }
    }

    @ViewBuilder
    private func transitionComposite(in size: CGSize) -> some View {
        if reduceMotion {
            staticComposite(in: size)
        } else {
            animatedComposite(in: size)
        }
    }

    private func staticComposite(in size: CGSize) -> some View {
        (eventSnapshot.nextImage ?? eventSnapshot.currentImage)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
            .position(x: size.width * 0.5, y: size.height * 0.5)
    }

    private func animatedComposite(in size: CGSize) -> some View {
        let fullCoverageRadius = TransitionRevealModifier.maxRadius(
            for: size,
            origin: eventSnapshot.transitionOrigin,
            feather: tuningSnapshot.transitionFeather
        )

        return Color.clear
            .frame(width: size.width, height: size.height)
            .keyframeAnimator(
                initialValue: 0.0,
                trigger: eventSnapshot.transitionTrigger
            ) { _, elapsedTime in
                ZStack {
                    eventSnapshot.currentImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .clipped()

                    if let nextImage = eventSnapshot.nextImage {
                        nextImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipped()
                            .modifier(
                                TransitionRevealModifier(
                                    origin: eventSnapshot.transitionOrigin,
                                    elapsedTime: elapsedTime,
                                    duration: eventSnapshot.transitionDuration,
                                    maxRadius: fullCoverageRadius,
                                    feather: tuningSnapshot.transitionFeather
                                )
                            )
                    }
                }
                .frame(width: size.width, height: size.height)
            } keyframes: { _ in
                MoveKeyframe(0.0)
                LinearKeyframe(
                    eventSnapshot.transitionDuration,
                    duration: eventSnapshot.transitionDuration
                )
            }
            .position(x: size.width * 0.5, y: size.height * 0.5)
    }

    private var accessibilityOrigin: CGPoint {
        CGPoint(
            x: canvasSize.width * 0.5,
            y: canvasSize.height * 0.5
        )
    }
}
