#if canImport(UIKit)
import UIKit

struct PreparedImageProvider {
    private let images: [UIImage]

    init(assetNames: [String], maxPixelSize: CGFloat) {
        let preparedImages = assetNames.map {
            Self.preparedImage(named: $0, maxPixelSize: maxPixelSize)
        }
        let firstValidImage = preparedImages.compactMap { $0 }.first ?? Self.emptyFallbackImage()

        images = zip(assetNames, preparedImages).map { name, preparedImage in
            guard let preparedImage else {
                assertionFailure("Missing image asset named \(name)")
                return firstValidImage
            }
            return preparedImage
        }
    }

    func image(at index: Int) -> UIImage {
        images[index]
    }

    private static func preparedImage(named name: String, maxPixelSize: CGFloat) -> UIImage? {
        guard let originalImage = UIImage(named: name) else {
            return nil
        }

        let originalPixelWidth = originalImage.size.width * originalImage.scale
        let originalPixelHeight = originalImage.size.height * originalImage.scale
        let originalMaxPixelSize = max(originalPixelWidth, originalPixelHeight)
        let cappedMaxPixelSize = max(maxPixelSize, 1)

        guard originalMaxPixelSize > cappedMaxPixelSize else {
            if #available(iOS 15.0, *), let prepared = originalImage.preparingForDisplay() {
                return prepared
            }
            return originalImage
        }

        let scale = cappedMaxPixelSize / originalMaxPixelSize
        let targetPixelSize = CGSize(
            width: max(1, floor(originalPixelWidth * scale)),
            height: max(1, floor(originalPixelHeight * scale))
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        // Render at scale 1 so the renderer's numeric size matches the output pixel size.
        format.scale = 1

        let renderedImage = UIGraphicsImageRenderer(size: targetPixelSize, format: format).image { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: targetPixelSize))
        }

        if #available(iOS 15.0, *), let prepared = renderedImage.preparingForDisplay() {
            return prepared
        }
        return renderedImage
    }

    private static func emptyFallbackImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = 1

        return UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1), format: format).image { _ in }
    }
}
#endif
