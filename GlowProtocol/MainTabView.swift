//
//  MainTabView.swift
//  GlowProtocol
//
//  Custom floating tab bar over the three primary screens.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .daily

    enum Tab: Hashable {
        case daily
        case scrapbook
        case progress
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            tabBar
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .daily: DailyGlowView()
        case .scrapbook: ScrapbookView()
        case .progress: ProgressDashboardView()
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem(.daily, icon: "sun.min", selectedIcon: "sun.max.fill", label: "Today")
            tabItem(.scrapbook, icon: "square.grid.2x2", selectedIcon: "square.grid.2x2.fill", label: "Scrapbook")
            tabItem(.progress, icon: "chart.bar", selectedIcon: "chart.bar.fill", label: "Progress")
        }
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.large, style: .continuous)
                .fill(Color.glowSurface)
        )
        .glowFloatingShadow()
    }

    private func tabItem(_ tab: Tab, icon: String, selectedIcon: String, label: String) -> some View {
        let selected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = tab
            }
            HapticService.shared.play(.lightTap)
        } label: {
            VStack(spacing: 2) {
                Image(systemName: selected ? selectedIcon : icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(selected ? Color.glowTextPrimary : Color.glowTextSecondary)
                if selected {
                    Text(label)
                        .font(.glowSans(size: 10, weight: .bold))
                        .foregroundStyle(Color.glowTextPrimary)
                    Capsule()
                        .fill(Color.glowTextPrimary)
                        .frame(width: 4, height: 4)
                        .padding(.top, 2)
                } else {
                    Spacer().frame(height: 12)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
