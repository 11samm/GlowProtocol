//
//  ScrapbookPhoto.swift
//  GlowProtocol
//
//  Metadata for photos stored under Documents/Scrapbook/. The actual image
//  lives on disk; this record carries a relative path + a tiny grid thumbnail.
//

import Foundation
import SwiftData

@Model
final class ScrapbookPhoto {
    var date: Date
    var dayNumber: Int
    var fileURL: String
    var thumbnailData: Data?
    var capturedAt: Date
    var runID: UUID
    var isCurrentRun: Bool

    init(
        date: Date,
        dayNumber: Int,
        fileURL: String,
        thumbnailData: Data?,
        capturedAt: Date,
        runID: UUID,
        isCurrentRun: Bool = true
    ) {
        self.date = date
        self.dayNumber = dayNumber
        self.fileURL = fileURL
        self.thumbnailData = thumbnailData
        self.capturedAt = capturedAt
        self.runID = runID
        self.isCurrentRun = isCurrentRun
    }
}
