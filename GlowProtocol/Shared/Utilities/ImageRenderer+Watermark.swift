//
//  ImageRenderer+Watermark.swift
//  GlowProtocol
//
//  Helper for compositing a before/after slider with the Glow Protocol watermark.
//

import SwiftUI
import UIKit

enum WatermarkExporter {
    /// Renders a 1080×1080 export image of a before/after pair with the
    /// GLOW PROTOCOL wordmark composited in the top-left and day range in the bottom-right.
    static func render(before: UIImage?, after: UIImage?, beforeDay: Int, afterDay: Int) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            UIColor(Color.glowBackground).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            // Frame both images side-by-side, square cropping inside their halves.
            let half = CGRect(x: 0, y: 0, width: size.width / 2, height: size.height)
            let halfRight = CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height)
            drawAspectFill(before, in: half, ctx: ctx)
            drawAspectFill(after, in: halfRight, ctx: ctx)

            // Divider hairline.
            UIColor.white.withAlphaComponent(0.9).setFill()
            ctx.fill(CGRect(x: size.width / 2 - 1, y: 0, width: 2, height: size.height))

            // BEFORE / AFTER pill labels.
            drawLabel("BEFORE", at: CGPoint(x: 24, y: 24), in: ctx.cgContext)
            drawLabel("AFTER", at: CGPoint(x: size.width / 2 + 24, y: 24), in: ctx.cgContext)

            // Glow Protocol wordmark — top-left corner overlay.
            let brand = NSAttributedString(string: "GLOW PROTOCOL", attributes: [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: UIColor.white,
                .kern: NSNumber(value: 6),
            ])
            brand.draw(at: CGPoint(x: 24, y: size.height - 90))

            let range = NSAttributedString(string: "Day \(beforeDay) → Day \(afterDay)", attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85),
            ])
            range.draw(at: CGPoint(x: 24, y: size.height - 56))
        }
    }

    private static func drawAspectFill(_ image: UIImage?, in rect: CGRect, ctx: UIGraphicsImageRendererContext) {
        ctx.cgContext.saveGState()
        ctx.cgContext.addRect(rect)
        ctx.cgContext.clip()
        if let image {
            let imgRatio = image.size.width / image.size.height
            let rectRatio = rect.width / rect.height
            var draw = rect
            if imgRatio > rectRatio {
                let scaledWidth = rect.height * imgRatio
                draw = CGRect(x: rect.midX - scaledWidth / 2, y: rect.minY, width: scaledWidth, height: rect.height)
            } else {
                let scaledHeight = rect.width / imgRatio
                draw = CGRect(x: rect.minX, y: rect.midY - scaledHeight / 2, width: rect.width, height: scaledHeight)
            }
            image.draw(in: draw)
        } else {
            UIColor(white: 0.85, alpha: 1).setFill()
            ctx.fill(rect)
        }
        ctx.cgContext.restoreGState()
    }

    private static func drawLabel(_ text: String, at origin: CGPoint, in ctx: CGContext) {
        let attr = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.white,
            .kern: NSNumber(value: 2),
        ])
        let size = attr.size()
        let padding: CGFloat = 8
        let pillRect = CGRect(
            x: origin.x,
            y: origin.y,
            width: size.width + padding * 2,
            height: size.height + padding
        )
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        let path = UIBezierPath(roundedRect: pillRect, cornerRadius: pillRect.height / 2)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        attr.draw(at: CGPoint(x: origin.x + padding, y: origin.y + padding / 2))
    }
}
