import SwiftUI

enum TaskCategory: String, CaseIterable {
    case work = "work"
    case breakTime = "break"
    case commute = "commute"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .work: return "仕事"
        case .breakTime: return "休憩"
        case .commute: return "移動"
        case .other: return "その他"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "📝"
        case .breakTime: return "☕"
        case .commute: return "🚶"
        case .other: return "📋"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .breakTime: return .orange
        case .commute: return .green
        case .other: return .gray
        }
    }
}
