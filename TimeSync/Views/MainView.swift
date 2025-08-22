import SwiftUI

struct MainView: View {
    @State private var timeEntries: [TimeEntry] = []
    @State private var showingAddEntry = false
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if timeEntries.isEmpty {
                emptyStateView
            } else {
                entryListView
            }
            
            Spacer()
        }
        .navigationTitle("TimeSync")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddEntry = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView { newEntry in
                timeEntries.append(newEntry)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 0) {
            Text("予定")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
            
            Divider()
                .frame(width: 1, height: 30)
            
            Text("実際")
                .font(.headline)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("まだタスクがありません")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("右上の＋ボタンからタスクを追加しましょう")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var entryListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(timeEntries) { entry in
                    TimeEntryRow(
                        entry: entry,
                        onEdit: { updatedEntry in
                            updateEntry(updatedEntry)
                        },
                        onDelete: { entryToDelete in
                            deleteEntry(entryToDelete)
                        },
                        onStartTimer: { entry in
                            // タイマー開始の処理は TimeEntryRow 内で完結
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
                isCompleted: true
            )
            timeEntries[index] = completedEntry
        }
    }
    
    private func loadSampleData() {
        timeEntries = [
            TimeEntry(
                taskName: "資料作成",
                category: .work,
                plannedDuration: 30 * 60,
                actualDuration: 25 * 60,
                isCompleted: true
            ),
            TimeEntry(
                taskName: "休憩",
                category: .breakTime,
                plannedDuration: 15 * 60,
                actualDuration: 20 * 60,
                isCompleted: true
            ),
            TimeEntry(
                taskName: "ミーティング準備",
                category: .work,
                plannedDuration: 20 * 60,
                isCompleted: false
            )
        ]
    }
}
