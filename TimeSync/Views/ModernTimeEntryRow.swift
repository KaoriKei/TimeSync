import SwiftUI

struct ModernTimeEntryRow: View {
    let entry: TimeEntry
    let onEdit: (TimeEntry) -> Void
    let onDelete: (TimeEntry) -> Void
    let onStartTimer: (TimeEntry) -> Void
    let onCompleteEntry: (TimeEntry, TimeInterval) -> Void
    
    @State private var showingEditSheet = false
    @State private var showingTimerSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // カテゴリアイコン
            ZStack {
                Circle()
                    .fill(entry.category.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text(entry.category.icon)
                    .font(.title2)
            }
            
            // タスク情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.taskName)
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(entry.scheduledTimeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    // 予定時間
                    HStack(spacing: 4) {
                        Text("予定")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(entry.plannedDurationText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // 実際時間
                    HStack(spacing: 4) {
                        Text("実際")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text(entry.actualDurationText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(entry.isCompleted ? (entry.isOvertime ? .red : .green) : .secondary)
                    }
                    
                    // 時間差
                    if entry.isCompleted && entry.timeDifference != 0 {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(entry.timeDifferenceText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(entry.isOvertime ? .red : .green)
                    }
                    
                    Spacer()
                }
            }
            
            // アクションボタン
            HStack(spacing: 8) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Button(action: {
                    onDelete(entry)
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingEditSheet) {
            ModernEditEntryView(entry: entry, onSave: { updatedEntry in
                onEdit(updatedEntry)
            }, onDelete: { entryToDelete in
                onDelete(entryToDelete)
            })
        }
        .sheet(isPresented: $showingTimerSheet) {
            TimerView(entry: entry) { actualTime in
                onCompleteEntry(entry, actualTime)
            }
        }
    }
}