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

    /// The run whose photos to compare. Always passed explicitly by the caller.
    var runID: UUID

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
        .onChange(of: beforeIndex) { oldValue, newValue in
            logSelectionChange(side: "Before", oldIndex: oldValue, newIndex: newValue)
        }
        .onChange(of: afterIndex) { oldValue, newValue in
            logSelectionChange(side: "After", oldIndex: oldValue, newIndex: newValue)
        }
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
        .zIndex(1)
    }

    private func picker(title: String, selection: Binding<Int>) -> some View {
        let currentIndex = selection.wrappedValue
        let atStart = currentIndex <= 0
        let atEnd = currentIndex >= allPhotos.count - 1
        let currentDay = allPhotos[safe: currentIndex]?.dayNumber ?? 0
        return VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .glowText(.caption)
                .foregroundStyle(Color.glowTextSecondary)
            HStack(spacing: 0) {
                Button {
                    let previousIndex = selection.wrappedValue
                    let newIndex = max(0, previousIndex - 1)
                    logPickerTap(
                        side: title,
                        direction: "left",
                        fromIndex: previousIndex,
                        toIndex: newIndex,
                        disabled: atStart
                    )
                    selection.wrappedValue = newIndex
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(atStart ? Color.glowTextSecondary.opacity(0.35) : Color.glowTextPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(atStart)

                Text("Day \(currentDay)")
                    .glowText(.subheadline)
                    .foregroundStyle(Color.glowTextPrimary)
                    .frame(minWidth: 52)

                Button {
                    let previousIndex = selection.wrappedValue
                    let newIndex = min(allPhotos.count - 1, previousIndex + 1)
                    logPickerTap(
                        side: title,
                        direction: "right",
                        fromIndex: previousIndex,
                        toIndex: newIndex,
                        disabled: atEnd
                    )
                    selection.wrappedValue = newIndex
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(atEnd ? Color.glowTextSecondary.opacity(0.35) : Color.glowTextPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(atEnd)
            }
        }
    }

    private var comparisonFrame: some View {
        // GeometryReader expands to fill a VStack unless constrained. Using
        // aspectRatio on a clear placeholder keeps hit testing off the pickers.
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { geo in
                    let side = min(geo.size.width, geo.size.height)
                    ZStack {
                        let beforeImage = loadImage(at: beforeIndex)
                        let afterImage = loadImage(at: afterIndex)

                        if let after = afterImage {
                            Image(uiImage: after)
                                .resizable()
                                .scaledToFill()
                                .frame(width: side, height: side)
                                .clipped()
                        }
                        if let before = beforeImage {
                            Image(uiImage: before)
                                .resizable()
                                .scaledToFill()
                                .frame(width: side, height: side)
                                .clipped()
                                .mask(
                                    HStack {
                                        Rectangle()
                                            .frame(width: max(0, side / 2 + dragX))
                                        Spacer(minLength: 0)
                                    }
                                )
                        }

                        // Slider divider
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: side)
                            .offset(x: dragX)
                        Circle()
                            .fill(Color.glowSurface)
                            .frame(width: 28, height: 28)
                            .glowFloatingShadow()
                            .offset(x: dragX)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let half = side / 2
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
                    .frame(width: side, height: side)
                    .onAppear { frameSize = CGSize(width: side, height: side) }
                }
            }
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
        // Fetch every photo that belongs to this run, ordered by day number.
        // No date arithmetic — just the photos that exist, in the order they
        // were taken. If a day was skipped it simply isn't in the array.
        let targetID = runID
        let allDescriptor = FetchDescriptor<ScrapbookPhoto>(
            sortBy: [
                SortDescriptor(\ScrapbookPhoto.dayNumber, order: .forward),
                SortDescriptor(\ScrapbookPhoto.date, order: .forward)
            ]
        )
        let everyPhoto = (try? context.fetch(allDescriptor)) ?? []

        let descriptor = FetchDescriptor<ScrapbookPhoto>(
            predicate: #Predicate<ScrapbookPhoto> { $0.runID == targetID },
            sortBy: [SortDescriptor(\ScrapbookPhoto.dayNumber, order: .forward)]
        )
        allPhotos = (try? context.fetch(descriptor)) ?? []
        beforeIndex = 0
        afterIndex = max(0, allPhotos.count - 1)

        logLoad(targetRunID: targetID, everyPhoto: everyPhoto)
        logSelectionState(context: "after load")
    }

    private func logLoad(targetRunID: UUID, everyPhoto: [ScrapbookPhoto]) {
        GlowDebugLog.beforeAfter("load runID=\(targetRunID.uuidString.prefix(8))… totalPhotosInDB=\(everyPhoto.count) matchedRunPhotos=\(allPhotos.count)")

        for (index, photo) in everyPhoto.enumerated() {
            let matchesRun = photo.runID == targetRunID
            GlowDebugLog.beforeAfter(
                "  db[\(index)] day=\(photo.dayNumber) date=\(photo.date.glowShortDayLabel) " +
                "runID=\(photo.runID.uuidString.prefix(8))… currentRun=\(photo.isCurrentRun) " +
                "file=\(photo.fileURL) matchesTargetRun=\(matchesRun)"
            )
        }

        for (index, photo) in allPhotos.enumerated() {
            GlowDebugLog.beforeAfter(
                "  picker[\(index)] day=\(photo.dayNumber) date=\(photo.date.glowShortDayLabel) " +
                "runID=\(photo.runID.uuidString.prefix(8))… file=\(photo.fileURL)"
            )
        }

        let excluded = everyPhoto.filter { $0.runID != targetRunID }
        if !excluded.isEmpty {
            GlowDebugLog.beforeAfter(
                "  excludedFromPicker=\(excluded.count) (likely runID mismatch — scrapbook shows these by date, not runID)"
            )
        }

        let dayNumbers = allPhotos.map(\.dayNumber)
        if Set(dayNumbers).count != dayNumbers.count {
            GlowDebugLog.beforeAfter("  WARNING duplicate dayNumbers in picker array: \(dayNumbers)")
        }
    }

    private func logPickerTap(
        side: String,
        direction: String,
        fromIndex: Int,
        toIndex: Int,
        disabled: Bool
    ) {
        let fromDay = allPhotos[safe: fromIndex]?.dayNumber ?? -1
        let toDay = allPhotos[safe: toIndex]?.dayNumber ?? -1
        GlowDebugLog.beforeAfter(
            "tap \(side) \(direction) disabled=\(disabled) " +
            "index \(fromIndex)->\(toIndex) day \(fromDay)->\(toDay) " +
            "photoCount=\(allPhotos.count)"
        )
    }

    private func logSelectionChange(side: String, oldIndex: Int, newIndex: Int) {
        guard oldIndex != newIndex else { return }
        let oldDay = allPhotos[safe: oldIndex]?.dayNumber ?? -1
        let newDay = allPhotos[safe: newIndex]?.dayNumber ?? -1
        GlowDebugLog.beforeAfter(
            "selection \(side) changed index \(oldIndex)->\(newIndex) day \(oldDay)->\(newDay)"
        )
        logSelectionState(context: "\(side) selection changed")
    }

    private func logSelectionState(context: String) {
        let beforeDay = allPhotos[safe: beforeIndex]?.dayNumber ?? -1
        let afterDay = allPhotos[safe: afterIndex]?.dayNumber ?? -1
        let beforeFile = allPhotos[safe: beforeIndex]?.fileURL ?? "nil"
        let afterFile = allPhotos[safe: afterIndex]?.fileURL ?? "nil"
        GlowDebugLog.beforeAfter(
            "\(context): beforeIndex=\(beforeIndex) day=\(beforeDay) file=\(beforeFile) | " +
            "afterIndex=\(afterIndex) day=\(afterDay) file=\(afterFile)"
        )
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
