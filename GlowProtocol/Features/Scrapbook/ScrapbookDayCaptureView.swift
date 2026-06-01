//
//  ScrapbookDayCaptureView.swift
//  GlowProtocol
//
//  Dev affordance: capture (or replace) a progress photo for an arbitrary day
//  directly from the Scrapbook grid. Saves straight through PhotoService for
//  the target date — independent of the daily checklist flow.
//

import SwiftUI
import UIKit
import SwiftData

struct ScrapbookDayCaptureView: View {
    let date: Date
    let dayNumber: Int
    let runID: UUID
    let onSaved: () -> Void
    let onCancel: () -> Void

    @Environment(\.modelContext) private var context

    @State private var captured: UIImage?
    @State private var saving = false
    @State private var fallbackToLibrary = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if UIImagePickerController.isSourceTypeAvailable(.camera), !fallbackToLibrary {
                CameraPicker(image: $captured, onCancel: onCancel)
                    .ignoresSafeArea()
            } else {
                PhotoLibraryFallback(image: $captured, onCancel: onCancel)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: captured) { _, newImage in
            guard let image = newImage else { return }
            handleCapture(image)
        }
    }

    private func handleCapture(_ image: UIImage) {
        guard !saving else { return }
        saving = true
        do {
            _ = try PhotoService.shared.savePhoto(
                image,
                for: date,
                dayNumber: dayNumber,
                runID: runID,
                in: context
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { onSaved() }
        } catch {
            saving = false
            onCancel()
        }
    }
}
