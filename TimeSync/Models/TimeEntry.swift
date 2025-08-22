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
    
    // メイン初期化メソッド（すべてのパラメータを受け取る）
    init(id: UUID = UUID(), taskName: String, category: TaskCategory, plannedDuration: TimeInterval, actualDuration: TimeInterval? = nil, startTime: Date = Date(), endTime: Date? = nil, isCompleted: Bool = false) {
        self.id = id
        self.taskName = taskName
        self.category = category
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }
    
    var plannedDurationText: String {
        let minutes = Int(plannedDuration / 60)
        return "\(minutes)分"
    }
    
    var actualDurationText: String {
        guard let duration = actualDuration else {
            return "---"
        }
        let minutes = Int(duration / 60)
        return "\(minutes)分"
    }
    
    var isOvertime: Bool {
        guard let actual = actualDuration else { return false }
        return actual > plannedDuration
    }
    
    var timeDifference: TimeInterval {
        guard let actual = actualDuration else { return 0 }
        return actual - plannedDuration
    }
}
