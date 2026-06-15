//
//  ScrapbookCell.swift
//  GlowProtocol
//
//  Calendar grid cell for the Scrapbook. Either shows a photo thumbnail,
//  a placeholder (passed day, no photo), or empty (future day).
//

import SwiftUI

struct ScrapbookCell: View {
    enum State {
        case filled(thumbnail: UIImage, dayNumber: Int, isToday: Bool, isArchived: Bool)
        case empty(dayNumber: Int, isToday: Bool)
        case future
    }

    let state: State

    var body: some View {
        // A fixed square footprint: the clear base fits the available cell
        // width and forces a 1:1 ratio, so every cell — photo or placeholder —
        // is identically sized. Photos fill + center-crop into the square.
        switch state {
        case .filled(let thumb, let day, let isToday, let archived):
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .background {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .overlay(alignment: .bottomLeading) {
                    DayBadge(dayNumber: day, style: .overlay)
                        .padding(6)
                }
                .overlay(alignment: .topTrailing) {
                    if archived {
                        Text("ARCHIVED")
                            .glowText(.badge)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.black.opacity(0.45)))
                            .padding(6)
                    }
                }
                .overlay {
                    if isToday {
                        Rectangle().strokeBorder(Color.glowTextPrimary, lineWidth: 2)
                    }
                }
                .clipShape(Rectangle())
        case .empty(let day, let isToday):
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay { emptyContent(day: day, isToday: isToday) }
                .clipShape(Rectangle())
        case .future:
            Color.clear
                .aspectRatio(1, contentMode: .fit)
        }
    }

    @ViewBuilder
    private func emptyContent(day: Int, isToday: Bool) -> some View {
        ZStack {
            Rectangle().fill(Color.glowSurfaceSecondary)
            VStack(spacing: 4) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.glowTextDisabled)
                Text("Day \(day)")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextDisabled)
            }
            if isToday {
                Rectangle().strokeBorder(Color.glowTextPrimary, lineWidth: 2)
            }
        }
    }
}
