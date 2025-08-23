import SwiftUI

enum TimeFilter: String, CaseIterable {
    case all = "すべて"
    case morning = "午前"
    case afternoon = "午後"
    
    var displayName: String {
        return self.rawValue
    }
}

struct MainView: View {
    @State private var timeEntries: [TimeEntry] = []
    @State private var selectedFilter: TimeFilter = .all
    
    var body: some View {
        VStack(spacing: 0) {
            summarySection
            filterSection
            
            if filteredEntries.isEmpty {
                emptyStateView
            } else {
                entryListView
            }
            
            Spacer()
        }
        .navigationTitle("TimeSync")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadSampleData()
        }
    }
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("今日のサマリー")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(totalPlannedTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("予定")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Text(totalActualTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("実際")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Text(progressPercentage)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                    Text("進捗")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var filterSection: some View {
        HStack {
            ForEach(TimeFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                }) {
                    Text(filter.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? Color.blue : Color(UIColor.systemGray5))
                        .cornerRadius(20)
                }
            }
            
            Spacer()
            
            Text("\(filteredEntries.count)件")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("まだタスクがありません")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("下部の「タスク追加」からタスクを追加しましょう")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var entryListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("今日のタスク")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
                
                LazyVStack(spacing: 12) {
                    ForEach(filteredEntries) { entry in
                        ModernTimeEntryRow(
                            entry: entry,
                            onEdit: { updatedEntry in
                                updateEntry(updatedEntry)
                            },
                            onDelete: { entryToDelete in
                                deleteEntry(entryToDelete)
                            },
                            onStartTimer: { entry in
                                // タイマー開始の処理
                            },
                            onCompleteEntry: { entry, actualTime in
                                completeEntry(entry, actualTime: actualTime)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var filteredEntries: [TimeEntry] {
        let filtered = timeEntries.filter { entry in
            switch selectedFilter {
            case .all:
                return true
            case .morning:
                return entry.timeOfDay == "午前"
            case .afternoon:
                return entry.timeOfDay == "午後"
            }
        }
        
        return filtered.sorted { entry1, entry2 in
            guard let time1 = entry1.scheduledTime, let time2 = entry2.scheduledTime else {
                return false
            }
            return time1 < time2
        }
    }
    
    private var totalPlannedTime: String {
        let total = timeEntries.reduce(0) { $0 + $1.plannedDuration }
        return formatDuration(total)
    }
    
    private var totalActualTime: String {
        let total = timeEntries.compactMap { $0.actualDuration }.reduce(0, +)
        return formatDuration(total)
    }
    
    private var progressPercentage: String {
        let planned = timeEntries.reduce(0) { $0 + $1.plannedDuration }
        let actual = timeEntries.compactMap { $0.actualDuration }.reduce(0, +)
        
        guard planned > 0 else { return "0%" }
        let percentage = Int((actual / planned) * 100)
        return "\(percentage)%"
    }
    
    private var progressColor: Color {
        let planned = timeEntries.reduce(0) { $0 + $1.plannedDuration }
        let actual = timeEntries.compactMap { $0.actualDuration }.reduce(0, +)
        
        guard planned > 0 else { return .gray }
        let ratio = actual / planned
        
        if ratio <= 1.0 {
            return .green
        } else if ratio <= 1.2 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return remainingMinutes > 0 ? "\(hours)時間\(remainingMinutes)分" : "\(hours)時間"
        } else {
            return "\(minutes)分"
        }
    }
    
    // MARK: - Private Methods
    
    private func updateEntry(_ updatedEntry: TimeEntry) {
        if let index = timeEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            timeEntries[index] = updatedEntry
        }
    }
    
    private func deleteEntry(_ entryToDelete: TimeEntry) {
        timeEntries.removeAll { $0.id == entryToDelete.id }
    }
    
    private func completeEntry(_ entry: TimeEntry, actualTime: TimeInterval) {
        if let index = timeEntries.firstIndex(where: { $0.id == entry.id }) {
            let completedEntry = TimeEntry(
                id: entry.id,
                taskName: entry.taskName,
                category: entry.category,
                plannedDuration: entry.plannedDuration,
                actualDuration: actualTime,
                startTime: entry.startTime,
                endTime: Date(),
                isCompleted: true,
                scheduledTime: entry.scheduledTime
            )
            timeEntries[index] = completedEntry
        }
    }
    
    private func loadSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        timeEntries = [
            TimeEntry(
                taskName: "アプリ作成",
                category: .work,
                plannedDuration: 2 * 3600, // 2時間
                actualDuration: 2.5 * 3600, // 2時間30分
                isCompleted: true,
                scheduledTime: calendar.date(bySettingHour: 13, minute: 29, second: 0, of: today)
            ),
            TimeEntry(
                taskName: "ランチ",
                category: .breakTime,
                plannedDuration: 35 * 60, // 35分
                actualDuration: 20 * 60, // 20分
                isCompleted: true,
                scheduledTime: calendar.date(bySettingHour: 11, minute: 58, second: 0, of: today)
            ),
            TimeEntry(
                taskName: "資料作成",
                category: .work,
                plannedDuration: 30 * 60, // 30分
                actualDuration: 50 * 60, // 50分
                isCompleted: true,
                scheduledTime: calendar.date(bySettingHour: 9, minute: 35, second: 0, of: today)
            )
        ]
    }
