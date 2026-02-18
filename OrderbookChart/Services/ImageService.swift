
import AppKit
import SwiftUI

@MainActor
final class ImageService {

    static let shared = ImageService()

    func chartSnapshotPNG(
        candleSize: Int,
        orderbookUnion: Int,
        candles: [Candle],
        orderbook: Orderbook?,
        rpiOrderbook: Orderbook?,
        height: CGFloat
    ) -> Data? {
        let chart = ChartView(
            candleSize: .constant(candleSize),
            orderbookUnion: .constant(orderbookUnion),
            candles: .constant(candles),
            orderbook: .constant(orderbook),
            rpiOrderbook: .constant(rpiOrderbook),
            isSnapshot: true
        )
        .frame(height: height)
        .background(Color(hex: "#171A24"))

        let renderer = ImageRenderer(content: chart)
        if let nsImage = renderer.nsImage {
            guard let tiffData = nsImage.tiffRepresentation,
                let bitmap = NSBitmapImageRep(data: tiffData),
                let pngData = bitmap.representation(using: .png, properties: [:])
            else {
                return nil
            }
            return pngData
        } else {
            return nil
        }
    }
}
