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
        ZStack {
            switch state {
            case .filled(let thumb, let day, let isToday, let archived):
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                VStack {
                    HStack {
                        Spacer()
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
                    Spacer()
                    HStack {
                        DayBadge(dayNumber: day, style: .overlay)
                            .padding(6)
                        Spacer()
                    }
                }
                if isToday {
                    Rectangle()
                        .strokeBorder(Color.glowTextPrimary, lineWidth: 2)
                }
            case .empty(let day, let isToday):
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
                    Rectangle()
                        .strokeBorder(Color.glowTextPrimary, lineWidth: 2)
                }
            case .future:
                Rectangle().fill(Color.glowBackground)
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .clipped()
    }
}
