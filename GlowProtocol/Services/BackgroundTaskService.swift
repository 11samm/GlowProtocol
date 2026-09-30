//
//  BackgroundTaskService.swift
//  GlowProtocol
//
//  Registers + handles BGAppRefreshTask for nightly streak evaluation.
//

import Foundation
import BackgroundTasks
import SwiftData

@MainActor
final class BackgroundTaskService {
    static let shared = BackgroundTaskService()
    static let midnightCheckIdentifier = "sam.GlowProtocol.midnight-check"

    private var container: ModelContainer?

    private init() {}

    func register(container: ModelContainer) {
        self.container = container
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.midnightCheckIdentifier,
            using: nil
        ) { [weak self] task in
            guard let task = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false); return
            }
            self?.handleMidnightCheck(task: task)
        }
    }

    func scheduleMidnightCheck() {
        let request = BGAppRefreshTaskRequest(identifier: Self.midnightCheckIdentifier)
        let calendar = Calendar.current
        request.earliestBeginDate = calendar.date(
            byAdding: .day, value: 1, to: calendar.startOfDay(for: .now)
        )
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Background tasks aren't supported in the simulator — fail silently.
        }
    }

    private func handleMidnightCheck(task: BGAppRefreshTask) {
        scheduleMidnightCheck()
        guard let container else {
            task.setTaskCompleted(success: false); return
        }

        let workTask = Task { @MainActor in
            let context = ModelContext(container)
            let service = StreakService(context: context)
            // Background scheduling is best effort. Only evaluate a closed day.
            let today = Date.now.glowStartOfDay
            if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
               yesterday >= service.fetchOrCreateConfig().startDate.glowStartOfDay {
                _ = service.evaluateDay(yesterday)
            }
            if UserDefaults.standard.bool(forKey: StreakService.pendingGraceDecisionKey),
               UserDefaults.standard.bool(forKey: StreakService.pendingGraceAvailableKey) {
                await NotificationService.shared.postGraceAvailableNotification()
            }
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            workTask.cancel()
        }
    }
}
