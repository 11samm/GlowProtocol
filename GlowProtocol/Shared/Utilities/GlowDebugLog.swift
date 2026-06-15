//
//  GlowDebugLog.swift
//  GlowProtocol
//
//  Lightweight debug logging for development builds. Filter in Console.app
//  with subsystem "sam.GlowProtocol" or category "BeforeAfter" / "PhotoService".
//

import Foundation
import os

enum GlowDebugLog {
    private static let subsystem = "sam.GlowProtocol"

    private static let beforeAfter = Logger(subsystem: subsystem, category: "BeforeAfter")
    private static let photoService = Logger(subsystem: subsystem, category: "PhotoService")
    private static let scrapbook = Logger(subsystem: subsystem, category: "Scrapbook")

    static func beforeAfter(_ message: String) {
        beforeAfter.debug("\(message, privacy: .public)")
    }

    static func photoService(_ message: String) {
        photoService.debug("\(message, privacy: .public)")
    }

    static func scrapbook(_ message: String) {
        scrapbook.debug("\(message, privacy: .public)")
    }
}
