//
//  PhotoService.swift
//  GlowProtocol
//
//  Filesystem-backed photo storage. Scrapbook photos live under
//  Documents/Scrapbook/<yyyy-MM-dd>.jpg as JPEGs (quality 0.82).
//

import Foundation
import UIKit
import SwiftData

@MainActor
final class PhotoService {
    static let shared = PhotoService()
    static let folderName = "Scrapbook"
    static let appGroupIdentifier = "group.sam.GlowProtocol"

    private init() {}

    /// The base URL where Scrapbook photos are stored.
    /// Prefers the App Group container (so widgets can see photos) and falls
    /// back to the app's Documents directory.
    func scrapbookDirectory() throws -> URL {
        let baseURL: URL
        if let appGroupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier) {
            baseURL = appGroupURL
        } else {
            baseURL = try FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true
            )
        }
        let dir = baseURL.appendingPathComponent(Self.folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func absoluteURL(forRelative path: String) throws -> URL {
        let dir = try scrapbookDirectory()
        return dir.appendingPathComponent(path)
    }

    /// Persists an image to disk and creates / updates the corresponding ScrapbookPhoto record.
    @discardableResult
    func savePhoto(
        _ image: UIImage,
        for date: Date,
        dayNumber: Int,
        runID: UUID,
        in context: ModelContext
    ) throws -> ScrapbookPhoto {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        let stamp = f.string(from: date.glowStartOfDay)
        let filename = "\(stamp).jpg"
        let fileURL = try absoluteURL(forRelative: filename)

        guard let data = image.jpegData(compressionQuality: 0.82) else {
            throw NSError(domain: "PhotoService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not encode image"])
        }
        try data.write(to: fileURL, options: .atomic)

        let thumb = downscale(image, maxDimension: 240)
        let thumbData = thumb.jpegData(compressionQuality: 0.55)

        let descriptor = FetchDescriptor<ScrapbookPhoto>()
        let existing = (try? context.fetch(descriptor))?.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        })

        if let existing {
            existing.fileURL = filename
            existing.thumbnailData = thumbData
            existing.capturedAt = .now
            existing.runID = runID
            existing.isCurrentRun = true
            try? context.save()
            return existing
        }

        let photo = ScrapbookPhoto(
            date: date.glowStartOfDay,
            dayNumber: dayNumber,
            fileURL: filename,
            thumbnailData: thumbData,
            capturedAt: .now,
            runID: runID,
            isCurrentRun: true
        )
        context.insert(photo)
        try? context.save()
        return photo
    }

    func loadImage(for relativePath: String) -> UIImage? {
        guard let url = try? absoluteURL(forRelative: relativePath) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func deletePhoto(_ relativePath: String) {
        guard let url = try? absoluteURL(forRelative: relativePath) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(maxDimension / max(size.width, 1), maxDimension / max(size.height, 1), 1)
        if scale >= 1 { return image }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
