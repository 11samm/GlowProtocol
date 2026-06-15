//
//  DailyGlowView.swift
//  GlowProtocol
//
//  THE main checklist screen — the screen the user opens every day.
//

import SwiftUI
import SwiftData

struct DailyGlowView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = DailyGlowViewModel()
    @State private var undoEntry: HabitEntry?
    @State private var sheetState: SheetState?
    @AppStorage("debugDayOffset") private var debugDayOffset: Int = 0

    enum SheetState: Identifiable {
        case workout(HabitEntry)
        case water(HabitEntry)
        case photo(HabitEntry, DayLog)

        var id: String {
            switch self {
            case .workout(let e): return "workout-\(e.persistentModelID.idString)"
            case .water(let e): return "water-\(e.persistentModelID.idString)"
            case .photo(let e, _): return "photo-\(e.persistentModelID.idString)"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.glowBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                        .padding(.horizontal, GlowSpacing.s16)
                        .padding(.top, GlowSpacing.s12)

                    dateStrip
                        .padding(.horizontal, GlowSpacing.s16)
                        .padding(.top, GlowSpacing.s16)

                    if let log = viewModel.todayLog {
                        habitListCard(log: log)
                            .padding(.top, GlowSpacing.s16)
                            .padding(.bottom, GlowSpacing.s24)

                        if viewModel.allComplete {
                            completionBanner
                                .padding(.horizontal, GlowSpacing.s16)
                                .transition(.opacity)
                        } else {
                            Color.clear.frame(height: GlowSpacing.s24)
                        }

                        devControls
                            .padding(.horizontal, GlowSpacing.s16)
                            .padding(.bottom, 120)
                    } else {
                        emptyPlaceholder
                            .padding(.top, 80)
                    }
                }
            }
        }
        .onAppear { viewModel.bind(context: context) }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { viewModel.refresh() }
        }
        .sheet(item: $sheetState) { state in
            switch state {
            case .workout(let entry):
                WorkoutTimerView(entry: entry, viewModel: viewModel)
            case .water(let entry):
                WaterTrackerView(entry: entry, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            case .photo(let entry, let log):
                PhotoCaptureView(entry: entry, dayLog: log, viewModel: viewModel)
            }
        }
        .sheet(item: $undoEntry) { entry in
            undoSheet(entry: entry)
                .presentationDetents([.height(220)])
        }
    }

    // MARK: - Sub-views

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Day \(viewModel.dayNumber)")
                    .font(.glowSerif(size: 38, weight: .bold, italic: true))
                    .foregroundStyle(Color.glowTextPrimary)
                Text("of \(viewModel.targetDays)")
                    .glowText(.body)
                    .foregroundStyle(Color.glowTextSecondary)
            }
            Spacer()
            ZStack {
                ProgressRing(progress: viewModel.completionPercentage)
                    .frame(width: 72, height: 72)
                Text("\(Int(viewModel.completionPercentage * 100))%")
                    .glowText(.headline)
                    .foregroundStyle(Color.glowTextPrimary)
            }
        }
    }

    private var dateStrip: some View {
        HStack {
            Text(Date.glowEffectiveNow.glowFullDayLabel)
                .glowText(.caption)
                .foregroundStyle(Color.glowTextSecondary)
            Spacer()
            if viewModel.allComplete {
                HStack(spacing: 4) {
                    Text("All done")
                        .glowText(.subheadline)
                        .foregroundStyle(Color.glowTextPrimary)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.glowTextPrimary)
                }
            }
        }
    }

    private func habitListCard(log: DayLog) -> some View {
        let entries = viewModel.sortedEntries
        return VStack(spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.element.persistentModelID) { idx, entry in
                let (status, emphasis) = viewModel.statusText(for: entry)
                HabitRow(
                    label: entry.displayLabel,
                    habitID: entry.habitID,
                    isComplete: entry.isComplete,
                    statusText: status,
                    statusEmphasis: emphasis,
                    trailing: viewModel.trailingStyle(for: entry),
                    photoThumbnail: photoThumbnail(for: entry, log: log),
                    iconSymbolOverride: entry.habitID.isCustom ? entry.customSymbolName : nil,
                    iconColorOverride: entry.habitID.isCustom
                        ? entry.customColorHex.map { Color(hex: $0) }
                        : nil,
                    onTap: { handleRowTap(entry, log: log) }
                )
                .transition(.glowMove)
                if idx < entries.count - 1 {
                    Rectangle()
                        .fill(Color.glowDivider)
                        .frame(height: 1)
                        .padding(.leading, 68)
                }
            }
        }
        .background(Color.glowSurface)
        .animation(GlowAnimation.standard, value: entries.map(\.isComplete))
    }

    private func photoThumbnail(for entry: HabitEntry, log: DayLog) -> UIImage? {
        guard entry.habitID == .progressPhoto, let path = log.photoFileURL else { return nil }
        return PhotoService.shared.loadImage(for: path)
    }

    private func handleRowTap(_ entry: HabitEntry, log: DayLog) {
        if entry.isComplete {
            undoEntry = entry
            return
        }
        switch entry.habitID {
        case .workout1, .workout2:
            // Re-open the sheet whether a session is already running or not.
            // WorkoutTimerView.onAppear calls service.start() only when needed.
            sheetState = .workout(entry)
        case .water:
            sheetState = .water(entry)
        case .progressPhoto:
            sheetState = .photo(entry, log)
        case .steps:
            viewModel.completeHabit(entry, metadata: #"{"confirmed":true}"#)
        default:
            viewModel.completeHabit(entry)
        }
    }

    private func undoSheet(entry: HabitEntry) -> some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s16) {
            GlowSheetHandle()
            Text("Undo \(entry.displayLabel)?")
                .glowText(.headline)
                .foregroundStyle(Color.glowTextPrimary)
                .padding(.top, GlowSpacing.s8)
            Text("This will move the habit back to incomplete.")
                .glowText(.body)
                .foregroundStyle(Color.glowTextSecondary)
            HStack(spacing: GlowSpacing.s12) {
                GlowButton(title: "Keep complete", style: .secondary) {
                    undoEntry = nil
                }
                GlowButton(title: "Undo", style: .ghost) {
                    viewModel.undoHabit(entry)
                    undoEntry = nil
                }
            }
            Spacer()
        }
        .padding(.horizontal, GlowSpacing.s24)
        .padding(.bottom, GlowSpacing.s24)
        .background(Color.glowSurface.ignoresSafeArea())
    }

    private var completionBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Protocol complete for today.")
                .glowText(.headline)
                .foregroundStyle(Color.glowSurface)
            Text("Come back tomorrow · Day \(viewModel.dayNumber + 1)")
                .glowText(.caption)
                .foregroundStyle(Color.glowSurface.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(GlowSpacing.s24)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .fill(Color.glowTextPrimary)
        )
    }

    private var emptyPlaceholder: some View {
        VStack(spacing: GlowSpacing.s16) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.glowTextSecondary)
            Text("Setting up today…")
                .glowText(.body)
                .foregroundStyle(Color.glowTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Dev Controls (temporary)

    private var devControls: some View {
        VStack(alignment: .leading, spacing: GlowSpacing.s8) {
            HStack(spacing: 4) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.glowTextSecondary)
                Text("DEV CONTROLS")
                    .glowText(.badge)
                    .foregroundStyle(Color.glowTextSecondary)
                    .tracking(2)
            }
            HStack(spacing: GlowSpacing.s8) {
                Button {
                    viewModel.markTodayHeldForDebug()
                    debugDayOffset += 1
                    viewModel.refresh()
                } label: {
                    Label("Skip Day +", systemImage: "forward.fill")
                        .glowText(.subheadline)
                        .foregroundStyle(Color.glowTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.glowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: GlowRadius.small, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    debugDayOffset = 0
                    viewModel.refresh()
                } label: {
                    Label("Reset to Now", systemImage: "clock.arrow.circlepath")
                        .glowText(.subheadline)
                        .foregroundStyle(debugDayOffset == 0 ? Color.glowTextSecondary : Color.glowTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.glowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: GlowRadius.small, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(debugDayOffset == 0)
            }
            if debugDayOffset != 0 {
                Text("Simulating +\(debugDayOffset) day\(debugDayOffset == 1 ? "" : "s") ahead · \(Date.glowEffectiveNow.glowFullDayLabel)")
                    .glowText(.caption)
                    .foregroundStyle(Color.glowTextSecondary)
            }
        }
        .padding(GlowSpacing.s16)
        .background(
            RoundedRectangle(cornerRadius: GlowRadius.medium, style: .continuous)
                .stroke(Color.glowDivider, lineWidth: 1)
        )
    }
}
