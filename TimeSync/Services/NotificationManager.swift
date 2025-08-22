import UserNotifications
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("通知権限が許可されました")
            } else {
                print("通知権限が拒否されました")
            }
        }
    }
    
    func scheduleRegularReminder(interval: TimeInterval, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "TimeSync"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: "regular_reminder_\(interval)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error)")
            }
        }
    }
    
    func scheduleTaskNotification(for entry: TimeEntry, type: NotificationType) {
        let content = UNMutableNotificationContent()
        content.title = "TimeSync"
        content.sound = .default
        
        var trigger: UNNotificationTrigger?
        
        switch type {
        case .plannedTimeReached:
            content.body = "\(entry.taskName)の予定時間になりました！"
            if let startTime = entry.startTime ?? nil {
                let notificationTime = startTime.addingTimeInterval(entry.plannedDuration)
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationTime),
                    repeats: false
                )
            }
            
        case .overtime(let overMinutes):
            content.body = "\(entry.taskName)が予定より\(overMinutes)分オーバーしています"
            if let startTime = entry.startTime ?? nil {
                let notificationTime = startTime.addingTimeInterval(entry.plannedDuration + TimeInterval(overMinutes * 60))
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationTime),
                    repeats: false
                )
            }
        }
        
        guard let trigger = trigger else { return }
        
        let request = UNNotificationRequest(
            identifier: "task_notification_\(entry.id)_\(type.identifier)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("タスク通知エラー: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func setupNotificationCategories() {
        let quickRecordAction = UNNotificationAction(
            identifier: "QUICK_RECORD",
            title: "クイック記録",
            options: [.foreground]
        )
        
        let reminderCategory = UNNotificationCategory(
            identifier: "REMINDER_CATEGORY",
            actions: [quickRecordAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
    }
}

enum NotificationType {
    case plannedTimeReached
    case overtime(minutes: Int)
    
    var identifier: String {
        switch self {
        case .plannedTimeReached:
            return "planned_time_reached"
        case .overtime(let minutes):
            return "overtime_\(minutes)"
        }
    }
}

extension NotificationManager {
    func scheduleDefaultReminders() {
        let messages = [
            "今何してる？📝 予定と実際を記録しよう",
            "時間の記録はできてますか？⏰",
            "予実管理で効率アップ！✨"
        ]
        
        scheduleRegularReminder(interval: 30 * 60, message: messages.randomElement() ?? messages[0])
    }
}
