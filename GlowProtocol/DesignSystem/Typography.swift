//
//  Typography.swift
//  GlowProtocol
//
//  The type system. Pairs Playfair Display (editorial serif, when registered) with SF Pro.
//  Serif is used at most once per screen; everything functional is SF Pro.
//

import SwiftUI
import UIKit

enum GlowFont {
    static let serifRegularName = "PlayfairDisplay-Regular"
    static let serifItalicName = "PlayfairDisplay-Italic"

    /// True when the bundled Playfair Display fonts registered successfully at launch.
    static var serifAvailable: Bool {
        UIFont.fontNames(forFamilyName: "Playfair Display").isEmpty == false
            || UIFont(name: serifRegularName, size: 12) != nil
    }
}

extension Font {
    /// Editorial serif — falls back to the system serif design when Playfair isn't available.
    static func glowSerif(size: CGFloat, weight: Font.Weight = .regular, italic: Bool = false) -> Font {
        let name = italic ? GlowFont.serifItalicName : GlowFont.serifRegularName
        if GlowFont.serifAvailable {
            return Font.custom(name, size: size).weight(weight)
        }
        var f = Font.system(size: size, weight: weight, design: .serif)
        if italic { f = f.italic() }
        return f
    }

    /// SF Pro sans — uses the system font directly.
    static func glowSans(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        Font.system(size: size, weight: weight, design: design)
    }

    /// SF Mono — for numerical countdowns and counters.
    static func glowMono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }
}

/// Named typography tokens that map to the blueprint's style table.
enum GlowTypeToken {
    case displayHero
    case displayTitle
    case displaySubtitle
    case headline
    case subheadline
    case body
    case caption
    case mono
    case badge

    var font: Font {
        switch self {
        case .displayHero:
            return .glowSerif(size: 44, weight: .bold, italic: true)
        case .displayTitle:
            return .glowSerif(size: 32, weight: .regular, italic: true)
        case .displaySubtitle:
            return .glowSerif(size: 24, weight: .regular)
        case .headline:
            return .glowSans(size: 17, weight: .semibold)
        case .subheadline:
            return .glowSans(size: 15, weight: .medium)
        case .body:
            return .glowSans(size: 15, weight: .regular)
        case .caption:
            return .glowSans(size: 12, weight: .regular)
        case .mono:
            return .glowMono(size: 14, weight: .regular)
        case .badge:
            return .glowSans(size: 11, weight: .bold, design: .rounded)
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .displayHero: return 44 * 0.1
        case .displayTitle: return 32 * 0.15
        case .displaySubtitle: return 24 * 0.2
        case .headline: return 17 * 0.3
        case .subheadline: return 15 * 0.35
        case .body: return 15 * 0.5
        case .caption: return 12 * 0.4
        case .mono: return 0
        case .badge: return 0
        }
    }

    var tracking: CGFloat {
        switch self {
        case .displayHero, .displayTitle: return -0.3
        case .badge: return 0.4
        default: return 0
        }
    }
}

struct GlowStyleModifier: ViewModifier {
    let token: GlowTypeToken

    func body(content: Content) -> some View {
        content
            .font(token.font)
            .lineSpacing(token.lineSpacing)
            .tracking(token.tracking)
    }
}

extension View {
    /// Applies a named typography token from the design system.
    func glowText(_ token: GlowTypeToken) -> some View {
        modifier(GlowStyleModifier(token: token))
    }
}
