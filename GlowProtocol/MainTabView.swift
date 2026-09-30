//
//  MainTabView.swift
//  GlowProtocol
//
//  Custom floating tab bar over the primary screens.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .daily

    enum Tab: Hashable {
        case daily
        case scrapbook
        case progress
        case friends
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
                .padding(.horizontal, GlowSpacing.s24)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
                .background {
                    ZStack {
                        Rectangle()
                            .fill(.regularMaterial)
                            .mask {
                                LinearGradient(
                                    stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .black.opacity(0.65), location: 0.35),
                                        .init(color: .black, location: 0.65),
                                        .init(color: .black, location: 1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                            .padding(.top, -72)
                            .ignoresSafeArea(.container, edges: .bottom)
                            .allowsHitTesting(false)

                        // Keep the tap shield independent of the visual fade:
                        // even the transparent margins must absorb touches.
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {}
                            .ignoresSafeArea(.container, edges: .bottom)
                    }
                    .accessibilityHidden(true)
                }
        }
        .onAppear {
            if FriendsService.shared.pendingInviteCode != nil { selectedTab = .friends }
            applyRequestedTab()
        }
        .onChange(of: FriendsService.shared.requestedHomeTab) { _, _ in applyRequestedTab() }
    }

    private func applyRequestedTab() {
        guard let destination = FriendsService.shared.requestedHomeTab else { return }
        selectedTab = destination == "friends" ? .friends : .daily
        FriendsService.shared.requestedHomeTab = nil
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .daily: DailyGlowView()
        case .scrapbook: ScrapbookView()
        case .progress: ProgressDashboardView()
        case .friends: FriendsView()
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem(.daily, icon: "sun.min", selectedIcon: "sun.max.fill", label: "Today")
            tabItem(.scrapbook, icon: "square.grid.2x2", selectedIcon: "square.grid.2x2.fill", label: "Scrapbook")
            tabItem(.progress, icon: "chart.bar", selectedIcon: "chart.bar.fill", label: "Progress")
            tabItem(.friends, icon: "person.2", selectedIcon: "person.2.fill", label: "Friends")
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
            .frame(maxWidth: .infinity, minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
