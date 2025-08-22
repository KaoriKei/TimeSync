import SwiftUI

struct TimeEntryRow: View {
    let entry: TimeEntry
    let onEdit: (TimeEntry) -> Void
    let onDelete: (TimeEntry) -> Void  // 削除コールバック追加
    let onStartTimer: (TimeEntry) -> Void
    let onCompleteEntry: (TimeEntry, TimeInterval) -> Void
    
    @State private var showingEditSheet = false
    @State private var showingTimerSheet = false
    
    var body: some View {
        HStack(spacing: 0) {
            plannedSection
            
            Divider()
                .frame(width: 1)
                .background(Color.gray.opacity(0.3))
            
            actualSection
        }
        .frame(height: 70)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingEditSheet) {
            EditEntryView(entry: entry, onSave: { updatedEntry in
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
    
    private var plannedSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.category.icon)
                    .font(.title2)
                
                Text(entry.taskName)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
            }
            
            Text(entry.plannedDurationText)
                .font(.caption)
                .foregroundColor(.blue)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditSheet = true
        }
    }
    
    private var actualSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.category.icon)
                    .font(.title2)
                
                Text(entry.taskName)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                if !entry.isCompleted {
                    // 未完了の場合：開始ボタン表示
                    Button(action: {
                        showingTimerSheet = true
                    }) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                } else if entry.isOvertime {
                    // 完了＆超過の場合：警告アイコン
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            HStack {
                Text(entry.actualDurationText)
                    .font(.caption)
                    .foregroundColor(entry.isCompleted ? (entry.isOvertime ? .red : .green) : .secondary)
                    .fontWeight(.semibold)
                
                if entry.isCompleted && entry.timeDifference != 0 {
                    Text(formatTimeDifference(entry.timeDifference))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            if !entry.isCompleted {
                showingTimerSheet = true
            } else {
                // 完了済みの場合は編集画面
                showingEditSheet = true
            }
        }
    }
    
    private func formatTimeDifference(_ difference: TimeInterval) -> String {
        let minutes = Int(abs(difference) / 60)
        let prefix = difference > 0 ? "+" : "-"
        return "(\(prefix)\(minutes)分)"
    }
}

// MARK: - EditEntryView
struct EditEntryView: View {
    let entry: TimeEntry
    let onSave: (TimeEntry) -> Void
    let onDelete: (TimeEntry) -> Void  // 削除コールバック追加
    
    @State private var taskName: String
    @State private var category: TaskCategory
    @State private var plannedDuration: TimeInterval
    @State private var actualDuration: TimeInterval?
    @State private var isCompleted: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    init(entry: TimeEntry, onSave: @escaping (TimeEntry) -> Void, onDelete: @escaping (TimeEntry) -> Void) {
        self.entry = entry
        self.onSave = onSave
        self.onDelete = onDelete
        _taskName = State(initialValue: entry.taskName)
        _category = State(initialValue: entry.category)
        _plannedDuration = State(initialValue: entry.plannedDuration)
        _actualDuration = State(initialValue: entry.actualDuration)
        _isCompleted = State(initialValue: entry.isCompleted)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("タスク情報") {
                    TextField("タスク名", text: $taskName)
                    
                    Picker("カテゴリ", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            HStack {
                                Text(cat.icon)
                                Text(cat.displayName)
                            }.tag(cat)
                        }
                    }
                }
                
                Section("時間") {
                    VStack(alignment: .leading) {
                        Text("予定時間: \(Int(plannedDuration / 60))分")
                        Slider(value: $plannedDuration, in: 300...7200, step: 300) // 5分〜2時間
                    }
                    
                    if isCompleted {
                        VStack(alignment: .leading) {
                            Text("実際時間: \(Int((actualDuration ?? 0) / 60))分")
                            Slider(value: Binding(
                                get: { actualDuration ?? plannedDuration },
                                set: { actualDuration = $0 }
                            ), in: 300...7200, step: 300)
                        }
                    }
                    
                    Toggle("完了済み", isOn: $isCompleted)
                        .onChange(of: isCompleted) {
                            // 完了済みをオフにした場合、実際時間をクリア
                            if !isCompleted {
                                actualDuration = nil
                            }
                        }
                }
                
                Section {
                    Button("削除", role: .destructive) {
                        onDelete(entry)  // 削除コールバック実行
                        dismiss()
                    }
                }
            }
            .navigationTitle("タスク編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let updatedEntry = TimeEntry(
                            id: entry.id,
                            taskName: taskName,
                            category: category,
                            plannedDuration: plannedDuration,
                            actualDuration: isCompleted ? actualDuration : nil,
                            startTime: entry.startTime,
                            endTime: isCompleted ? (entry.endTime ?? Date()) : nil,
                            isCompleted: isCompleted
                        )
                        onSave(updatedEntry)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - TimerView
struct TimerView: View {
    let entry: TimeEntry
    let onComplete: (TimeInterval) -> Void
    
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Text(entry.taskName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("予定: \(Int(entry.plannedDuration / 60))分")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 60, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    if elapsedTime > entry.plannedDuration {
                        Text("予定時間を\(Int((elapsedTime - entry.plannedDuration) / 60))分超過")
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 40) {
                    Button(action: toggleTimer) {
                        Text(isRunning ? "一時停止" : "開始")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50)
                            .background(isRunning ? Color.orange : Color.green)
                            .cornerRadius(25)
                    }
                    
                    Button(action: completeTask) {
                        Text("完了")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .disabled(elapsedTime < 60) // 1分未満は完了不可
                }
            }
            .padding()
            .navigationTitle("タイマー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        stopTimer()
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        if startTime == nil {
            startTime = Date()
        }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func completeTask() {
        stopTimer()
        onComplete(elapsedTime)
        dismiss()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
