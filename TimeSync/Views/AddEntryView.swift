import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskName = ""
    @State private var selectedCategory: TaskCategory = .work
    @State private var plannedHours = 0
    @State private var plannedMinutes = 30
    @State private var isTimerMode = false
    @State private var timerStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    let onSave: (TimeEntry) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("タスク情報") {
                    TextField("タスク名", text: $taskName)
                    
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.icon)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("予定時間") {
                    HStack {
                        Picker("時間", selection: $plannedHours) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour)時間").tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        
                        Picker("分", selection: $plannedMinutes) {
                            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minute in
                                Text("\(minute)分").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Section("実行モード") {
                    Toggle("タイマーモード", isOn: $isTimerMode)
                    
                    if isTimerMode {
                        timerSection
                    }
                }
            }
            .navigationTitle("新しいタスク")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTask()
                    }
                    .disabled(taskName.trim().isEmpty)
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var timerSection: some View {
        VStack(spacing: 16) {
            Text(formatElapsedTime(elapsedTime))
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(selectedCategory.color)
            
            HStack(spacing: 20) {
                Button(action: startTimer) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("開始")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(25)
                }
                .disabled(timer != nil)
                
                Button(action: stopTimer) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("停止")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(25)
                }
                .disabled(timer == nil)
            }
        }
        .padding()
    }
    
    private func startTimer() {
        timerStartTime = Date()
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = timerStartTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func saveTask() {
        let plannedDuration = TimeInterval((plannedHours * 60 + plannedMinutes) * 60)
        let actualDuration = isTimerMode && elapsedTime > 0 ? elapsedTime : nil
        
        let newEntry = TimeEntry(
            taskName: taskName.trim(),
            category: selectedCategory,
            plannedDuration: plannedDuration,
            actualDuration: actualDuration,
            startTime: timerStartTime ?? Date(),
            endTime: actualDuration != nil ? Date() : nil,
            isCompleted: actualDuration != nil
        )
        
        onSave(newEntry)
        dismiss()
    }
    
    private func formatElapsedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
