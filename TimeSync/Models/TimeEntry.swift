import SwiftUI
import Foundation

struct TimeEntry: Identifiable {
    let id: UUID
    let taskName: String
    let category: TaskCategory
    let plannedDuration: TimeInterval
    let actualDuration: TimeInterval?
    let startTime: Date
    let endTime: Date?
    let isCompleted: Bool
    let scheduledTime: Date? // 予定開始時刻
    
    // メイン初期化メソッド（すべてのパラメータを受け取る）
    init(id: UUID = UUID(), taskName: String, category: TaskCategory, plannedDuration: TimeInterval, actualDuration: TimeInterval? = nil, startTime: Date = Date(), endTime: Date? = nil, isCompleted: Bool = false, scheduledTime: Date? = nil) {
        self.id = id
        self.taskName = taskName
        self.category = category
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.scheduledTime = scheduledTime
    }
    
    var plannedDurationText: String {
        let minutes = Int(plannedDuration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return remainingMinutes > 0 ? "\(hours)時間\(remainingMinutes)分" : "\(hours)時間"
        } else {
            return "\(minutes)分"
        }
    }
    
    var actualDurationText: String {
        guard let duration = actualDuration else {
            return "---"
        }
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return remainingMinutes > 0 ? "\(hours)時間\(remainingMinutes)分" : "\(hours)時間"
        } else {
            return "\(minutes)分"
        }
    }
    
    var scheduledTimeText: String {
        guard let scheduledTime = scheduledTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: scheduledTime)
    }
    
    var timeOfDay: String {
        guard let scheduledTime = scheduledTime else { return "未設定" }
        let hour = Calendar.current.component(.hour, from: scheduledTime)
        return hour < 12 ? "午前" : "午後"
    }
    
    var isOvertime: Bool {
        guard let actual = actualDuration else { return false }
        return actual > plannedDuration
    }
    
    var timeDifference: TimeInterval {
        guard let actual = actualDuration else { return 0 }
        return actual - plannedDuration
    }
    
    var timeDifferenceText: String {
        let diff = timeDifference
        if diff == 0 { return "" }
        
        let minutes = Int(abs(diff) / 60)
        let prefix = diff > 0 ? "+" : "-"
        return "\(prefix)\(minutes)分"
    }
}
