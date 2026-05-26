//
//  BeforeAfterSliderView.swift
//  GlowProtocol
//
//  Drag-to-reveal before/after comparison + watermarked share export.
//

import SwiftUI
import SwiftData

struct BeforeAfterSliderView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var allPhotos: [ScrapbookPhoto] = []
    @State private var beforeIndex: Int = 0
    @State private var afterIndex: Int = 0
    @State private var dragX: CGFloat = 0
    @State private var frameSize: CGSize = .zero
    @State private var sharePackage: UIImage?

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()
            VStack(spacing: GlowSpacing.s16) {
                GlowSheetHandle()
                Text("Before & After")
                    .font(.glowSerif(size: 28, weight: .bold, italic: true))
                    .foregroundStyle(Color.glowTextPrimary)

                if allPhotos.isEmpty {
                    emptyState
                } else {
                    pickers
                    comparisonFrame
                    Text(watermarkPreview)
                        .glowText(.caption)
                        .foregroundStyle(Color.glowTextSecondary)
                    GlowButton(title: "Share") { generateShare() }
                        .padding(.horizontal, GlowSpacing.s24)
                }
                Spacer()
            }
            .padding(.top, GlowSpacing.s12)
            .padding(.bottom, GlowSpacing.s24)
        }
        .onAppear(perform: load)
        .sheet(item: Binding(get: { sharePackage.map(ShareItemBox.init) },
                              set: { _ in sharePackage = nil })) { box in
            ShareSheet(items: [box.image])
        }
    }

    private struct ShareItemBox: Identifiable {
        let image: UIImage
        var id: String { "share-package" }
    }

    private var emptyState: some View {
        VStack(spacing: GlowSpacing.s8) {
            Image(systemName: "rectangle.split.2x1")
                .font(.system(size: 32))
                .foregroundStyle(Color.glowTextSecondary)
                .padding(.top, GlowSpacing.s32)
            Text("Capture two progress photos to compare.")
                .glowText(.body)
                .foregroundStyle(Color.glowTextSecondary)
        }
    }

    private var pickers: some View {
        HStack(spacing: GlowSpacing.s24) {
            picker(title: "Before", selection: $beforeIndex)
            Rectangle().fill(Color.glowDivider).frame(width: 1, height: 40)
            picker(title: "After", selection: $afterIndex)
        }
        .padding(.horizontal, GlowSpacing.s24)
    }

    private func picker(title: String, selection: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .glowText(.caption)
                .foregroundStyle(Color.glowTextSecondary)
            HStack(spacing: 8) {
                Button {
                    selection.wrappedValue = max(0, selection.wrappedValue - 1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.plain)
                Text("Day \(allPhotos[safe: selection.wrappedValue]?.dayNumber ?? 0)")
                    .glowText(.subheadline)
                    .foregroundStyle(Color.glowTextPrimary)
                    .frame(minWidth: 60)
                Button {
                    selection.wrappedValue = min(allPhotos.count - 1, selection.wrappedValue + 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var comparisonFrame: some View {
        GeometryReader { geo in
            ZStack {
                let beforeImage = loadImage(at: beforeIndex)
                let afterImage = loadImage(at: afterIndex)

                if let after = afterImage {
                    Image(uiImage: after)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.width)
                        .clipped()
                }
                if let before = beforeImage {
                    Image(uiImage: before)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.width)
                        .clipped()
                        .mask(
                            HStack {
                                Rectangle()
                                    .frame(width: max(0, geo.size.width / 2 + dragX))
                                Spacer(minLength: 0)
                            }
                        )
                }

                // Slider divider
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: geo.size.width)
                    .offset(x: dragX)
                Circle()
                    .fill(Color.glowSurface)
                    .frame(width: 28, height: 28)
                    .glowFloatingShadow()
                    .offset(x: dragX)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let half = geo.size.width / 2
                                dragX = max(-half, min(half, value.translation.width))
                            }
                    )

                VStack {
                    HStack {
                        Text("BEFORE")
                            .glowText(.badge)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.black.opacity(0.45)))
                        Spacer()
                        Text("AFTER")
                            .glowText(.badge)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.black.opacity(0.45)))
                    }
                    .padding(12)
                    Spacer()
                }
            }
            .onAppear { frameSize = CGSize(width: geo.size.width, height: geo.size.width) }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
    }

    private func loadImage(at index: Int) -> UIImage? {
        guard let photo = allPhotos[safe: index] else { return nil }
        return PhotoService.shared.loadImage(for: photo.fileURL)
    }

    private var watermarkPreview: String {
        let b = allPhotos[safe: beforeIndex]?.dayNumber ?? 0
        let a = allPhotos[safe: afterIndex]?.dayNumber ?? 0
        return "Glow Protocol · Day \(b) → \(a)"
    }

    private func load() {
        let descriptor = FetchDescriptor<ScrapbookPhoto>(
            sortBy: [SortDescriptor(\ScrapbookPhoto.date, order: .forward)]
        )
        allPhotos = (try? context.fetch(descriptor)) ?? []
        beforeIndex = 0
        afterIndex = max(0, allPhotos.count - 1)
    }

    private func generateShare() {
        let b = loadImage(at: beforeIndex)
        let a = loadImage(at: afterIndex)
        let beforeDay = allPhotos[safe: beforeIndex]?.dayNumber ?? 1
        let afterDay = allPhotos[safe: afterIndex]?.dayNumber ?? 1
        if let img = WatermarkExporter.render(before: b, after: a, beforeDay: beforeDay, afterDay: afterDay) {
            sharePackage = img
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
