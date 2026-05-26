//
//  PhotoCaptureView.swift
//  GlowProtocol
//
//  UIImagePickerController bridge for capturing the daily progress photo.
//  Writes via PhotoService and auto-completes the habit on success.
//

import SwiftUI
import UIKit
import PhotosUI
import SwiftData

struct PhotoCaptureView: View {
    let entry: HabitEntry
    let dayLog: DayLog
    @Bindable var viewModel: DailyGlowViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var captured: UIImage?
    @State private var saving = false
    @State private var fallbackToLibrary = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if UIImagePickerController.isSourceTypeAvailable(.camera), !fallbackToLibrary {
                CameraPicker(image: $captured, onCancel: { dismiss() })
                    .ignoresSafeArea()
            } else {
                PhotoLibraryFallback(image: $captured, onCancel: { dismiss() })
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
            let photo = try PhotoService.shared.savePhoto(
                image,
                for: dayLog.date,
                dayNumber: dayLog.dayNumber,
                runID: dayLog.runID,
                in: context
            )
            viewModel.attachPhoto(photo.fileURL, for: dayLog)
            viewModel.completeHabit(entry, metadata: photo.fileURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { dismiss() }
        } catch {
            saving = false
            dismiss()
        }
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}

private struct PhotoLibraryFallback: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryFallback
        init(_ parent: PhotoLibraryFallback) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                parent.onCancel(); return
            }
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    if let image = object as? UIImage {
                        self.parent.image = image
                    } else {
                        self.parent.onCancel()
                    }
                }
            }
        }
    }
}
