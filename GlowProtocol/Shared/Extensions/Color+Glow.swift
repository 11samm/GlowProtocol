//
//  Color+Glow.swift
//  GlowProtocol
//
//  Additional Color conveniences not in the design system token file.
//

import SwiftUI
import UIKit

extension Color {
    /// Returns a darker variant of this color by a given fraction (used for borders / depth).
    func darkened(by amount: CGFloat) -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return Color(UIColor(hue: h, saturation: s, brightness: max(0, b - amount), alpha: a))
        }
        return self
    }
}
