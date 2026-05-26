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
        var components = calendar.dateComponents([.year, .month, .day], from: .now)
        components.hour = 23
        components.minute = 59
        components.second = 50
        if let date = calendar.date(from: components), date > .now {
            request.earliestBeginDate = date
        } else {
            request.earliestBeginDate = Date.now.addingTimeInterval(60 * 60)
        }
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
            _ = service.evaluateDay()
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
