//
//  ScrapbookView.swift
//  GlowProtocol
//
//  Calendar grid of daily photos. Tap a filled cell to view full-screen.
//

import SwiftUI
import SwiftData

struct ScrapbookView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ScrapbookViewModel()
    @State private var fullscreenPhoto: ScrapbookPhoto?
    @State private var captureTarget: CaptureTarget?
    @State private var showBeforeAfter = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                customNavBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.headerLabel)
                            .font(.glowSerif(size: 28, weight: .bold, italic: true))
                            .foregroundStyle(Color.glowTextPrimary)
                            .padding(.horizontal, GlowSpacing.s24)
                            .padding(.top, GlowSpacing.s8)

                        Text("Your 75 days, start to finish.")
                            .glowText(.caption)
                            .foregroundStyle(Color.glowTextSecondary)
                            .padding(.horizontal, GlowSpacing.s24)
                            .padding(.top, GlowSpacing.s4)

                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(viewModel.protocolDates, id: \.self) { date in
                                cell(for: date)
                                    .onTapGesture { handleTap(date) }
                            }
                        }
                        .padding(.top, GlowSpacing.s16)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .onAppear { viewModel.bind(context: context) }
        .fullScreenCover(item: $fullscreenPhoto) { photo in
            FullScreenPhotoView(photo: photo) { fullscreenPhoto = nil }
        }
        .fullScreenCover(item: $captureTarget) { target in
            ScrapbookDayCaptureView(
                date: target.date,
                dayNumber: target.dayNumber,
                runID: viewModel.currentRunID()
            ) {
                viewModel.refresh()
                captureTarget = nil
            } onCancel: {
                captureTarget = nil
            }
        }
        .sheet(isPresented: $showBeforeAfter) {
            BeforeAfterSliderView()
                .presentationDetents([.large])
        }
    }

    private var customNavBar: some View {
        HStack {
            Text("Scrapbook")
                .glowText(.headline)
                .foregroundStyle(Color.glowTextPrimary)
            Spacer()
            Button {
                showBeforeAfter = true
            } label: {
                Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.glowTextPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, GlowSpacing.s16)
        .padding(.vertical, GlowSpacing.s8)
    }

    private func cell(for date: Date) -> some View {
        ScrapbookCell(state: viewModel.cellState(for: date))
    }

    private func handleTap(_ date: Date) {
        if let photo = viewModel.photo(for: date) {
            fullscreenPhoto = photo
        } else if viewModel.isCaptureable(date) {
            // Dev affordance: tap any past/today cell to capture a photo for it.
            captureTarget = CaptureTarget(date: date.glowStartOfDay,
                                          dayNumber: viewModel.dayNumber(for: date))
        }
    }
}

/// Identifiable wrapper so an arbitrary day can drive a capture cover.
struct CaptureTarget: Identifiable {
    let date: Date
    let dayNumber: Int
    var id: TimeInterval { date.timeIntervalSince1970 }
}

struct FullScreenPhotoView: View {
    let photo: ScrapbookPhoto
    let onDismiss: () -> Void

    @State private var image: UIImage?
    @State private var dragOffset: CGFloat = 0
    @State private var shareItem: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 120 {
                                    onDismiss()
                                } else {
                                    withAnimation(.spring()) { dragOffset = 0 }
                                }
                            }
                    )
            }
            VStack {
                HStack {
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Spacer()
                    if let img = image {
                        Button {
                            shareItem = img
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding()
                        }
                    }
                }
                Spacer()
                HStack {
                    Text("Day \(photo.dayNumber) · \(photo.date.glowShortDayLabel)")
                        .glowText(.body)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.bottom, GlowSpacing.s24)
            }
        }
        .onAppear {
            image = PhotoService.shared.loadImage(for: photo.fileURL)
        }
        .sheet(item: Binding(get: { shareItem.map(ShareItemBox.init) },
                              set: { _ in shareItem = nil })) { box in
            ShareSheet(items: [box.image])
        }
    }
}

private struct ShareItemBox: Identifiable {
    let image: UIImage
    var id: String { "share" }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
