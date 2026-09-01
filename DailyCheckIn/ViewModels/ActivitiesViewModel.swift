//
//  ActivityViewModel.swift
//  DailyCheckIn
//

import Foundation
import Combine

final class ActivityViewModel: ObservableObject {
    
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var completions: [ActivityCompletion] = []
    
    private let storageService: ActivityStorageService
    
    init(
        storageService: ActivityStorageService = UserDefaultsActivityStorageService()
    ) {
        self.storageService = storageService
        self.activities = storageService.loadActivities()
        self.completions = storageService.loadCompletions()
    }
    
    // MARK: - Section Computed Properties
    
    /// Heute fällige, aktive Aufgaben (noch NICHT erledigt)
    var todayDueActivities: [Activity] {
        activities.filter { activity in
            activity.isActive &&
            isDue(activity, on: Date()) &&
            !isCompleted(activity, on: Date())
        }
    }
    
    /// Heute bereits ERLEDIGTE Aufgaben
    var todayCompletedActivities: [Activity] {
        activities.filter { activity in
            activity.isActive &&
            isDue(activity, on: Date()) &&
            isCompleted(activity, on: Date())
        }
    }
    
    /// Geplante Aufgaben für diese Woche (Aktiv, aber heute nicht fällig)
    var thisWeekPlannedActivities: [Activity] {
        activities.filter { activity in
            activity.isActive &&
            !isDue(activity, on: Date())
        }
    }
    
    /// Pausierte / Inaktive Aufgaben
    var pausedActivities: [Activity] {
        activities.filter { !$0.isActive }
    }
    
    // MARK: - Completion Logic
    
    func isCompleted(_ activity: Activity, on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return completions.contains { completion in
            completion.ActivityID == activity.id &&
            calendar.isDate(completion.date, inSameDayAs: date)
        }
    }
    
    func toggleCompletion(for activity: Activity, on date: Date = Date()) {
        let calendar = Calendar.current
        
        if let index = completions.firstIndex(where: { completion in
            completion.ActivityID == activity.id &&
            calendar.isDate(completion.date, inSameDayAs: date)
        }) {
            completions.remove(at: index)
        } else {
            completions.append(
                ActivityCompletion(activityID: activity.id, date: date)
            )
        }
        
        saveCompletions()
    }
    
    // MARK: - CRUD
    
    func addActivity(_ activity: Activity) {
        activities.insert(activity, at: 0)
        saveActivity()
    }
    
    func updateActivity(_ activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        activities[index] = activity
        saveActivity()
    }
    
    func deleteActivity(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        completions.removeAll { $0.ActivityID == activity.id }
        
        saveActivity()
        saveCompletions()
    }
    
    func toggleActive(_ activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        
        activities[index].isActive.toggle()
        let updatedActivity = activities[index]
        
        if updatedActivity.isActive {
            if updatedActivity.notificationsEnabled {
                NotificationManager.shared.scheduleNotifications(for: updatedActivity)
            }
        } else {
            NotificationManager.shared.cancelNotifications(for: updatedActivity)
        }
        
        saveActivity()
    }
    
    // MARK: - Helpers & Statistics
    
    func isDue(_ activity: Activity, on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        
        switch activity.recurrence {
        case .daily:
            return true
        case .weekly:
            let weekday = calendar.component(.weekday, from: date)
            return activity.selectedWeekdays.contains(weekday)
        case .monthly:
            return true
        }
    }
    
    func dueActivities(on date: Date = Date()) -> [Activity] {
        activities.filter { $0.isActive && isDue($0, on: date) }
    }
    
    private func startOfCurrentWeek(for date: Date = Date()) -> Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        ) ?? date
    }
    
    func weeklyTargetCount(referenceDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let weekStart = startOfCurrentWeek(for: referenceDate)
        
        return activities.reduce(0) { total, activity in
            guard activity.isActive else { return total }
            switch activity.recurrence {
            case .daily:
                return total + 7
            case .weekly:
                return total + activity.selectedWeekdays.count
            case .monthly:
                guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else { return total }
                let firstDay = calendar.startOfDay(for: weekStart)
                let lastDay = calendar.startOfDay(for: weekEnd)
                return firstDay <= lastDay ? total + 1 : total
            }
        }
    }
    
    func weeklyCompletedCount(referenceDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) else { return 0 }
        
        return completions.reduce(0) { count, completion in
            guard weekInterval.contains(completion.date) else { return count }
            guard let activity = activities.first(where: { $0.id == completion.ActivityID }) else { return count }
            guard isDue(activity, on: completion.date) else { return count }
            return count + 1
        }
    }
    
    // MARK: - Persistence
    
    private func saveActivity() {
        storageService.saveActivities(activities)
    }
    
    private func saveCompletions() {
        storageService.saveCompletions(completions)
    }
    
    func isFullyCompletedForWeek(activity: Activity) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return false
        }
        
        if activity.recurrence == .weekly && !activity.selectedWeekdays.isEmpty {
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start) {
                    let weekdayComponent = calendar.component(.weekday, from: date)
                    
                    if activity.selectedWeekdays.contains(weekdayComponent) {
                        if !isCompleted(activity, on: date) {
                            return false
                        }
                    }
                }
            }
            return true
        }
        
        var completedCount = 0
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start) {
                if isCompleted(activity, on: date) {
                    completedCount += 1
                }
            }
        }
        
        return completedCount >= activity.targetDaysPerWeek
    }
}
