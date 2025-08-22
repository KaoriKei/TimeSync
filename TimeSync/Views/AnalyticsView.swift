import SwiftUI

struct AnalyticsView: View {
    @State private var selectedPeriod: AnalyticsPeriod = .week
    @State private var analyticsData: [AnalyticsData] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                periodSelector
                
                if !analyticsData.isEmpty {
                    overviewCards
                    plannedVsActualChart
                    categoryBreakdownChart
                    efficiencyTrendChart
                } else {
                    emptyStateView
                }
            }
            .padding()
        }
        .navigationTitle("詳細分析")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadAnalyticsData()
        }
        .onChange(of: selectedPeriod) {
            loadAnalyticsData()
        }
    }
    
    private var periodSelector: some View {
        Picker("期間", selection: $selectedPeriod) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                Text(period.displayName).tag(period)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var overviewCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            OverviewCard(
                title: "総予定時間",
                value: formatHours(analyticsData.map(\.plannedHours).reduce(0, +)),
                icon: "clock",
                color: .blue
            )
            
            OverviewCard(
                title: "総実際時間",
                value: formatHours(analyticsData.map(\.actualHours).reduce(0, +)),
                icon: "stopwatch",
                color: .green
            )
            
            OverviewCard(
                title: "達成率",
                value: "\(calculateAchievementRate())%",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            
            OverviewCard(
                title: "効率スコア",
                value: "\(calculateEfficiencyScore())",
                icon: "target",
                color: .purple
            )
        }
    }
    
    private var plannedVsActualChart: some View {
        VStack(alignment: .leading) {
            Text("予定 vs 実際")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(analyticsData.prefix(7), id: \.date) { data in
                    HStack {
                        Text(formatDate(data.date))
                            .font(.caption)
                            .frame(width: 50, alignment: .leading)
                        
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: CGFloat(data.plannedHours * 20), height: 20)
                            
                            Rectangle()
                                .fill(Color.green.opacity(0.7))
                                .frame(width: CGFloat(data.actualHours * 20), height: 20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                }
                
                HStack {
                    Label("予定", systemImage: "square.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Label("実際", systemImage: "square.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading) {
            Text("カテゴリ別内訳")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    let hours = getCategoryHours(category)
                    HStack {
                        HStack {
                            Text(category.icon)
                            Text(category.displayName)
                                .font(.body)
                        }
                        .frame(width: 100, alignment: .leading)
                        
                        Rectangle()
                            .fill(category.color.opacity(0.8))
                            .frame(width: CGFloat(hours * 30), height: 20)
                            .cornerRadius(4)
                        
                        Text(formatHours(hours))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var efficiencyTrendChart: some View {
        VStack(alignment: .leading) {
            Text("効率トレンド")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(analyticsData.prefix(7), id: \.date) { data in
                    HStack {
                        Text(formatDate(data.date))
                            .font(.caption)
                            .frame(width: 50, alignment: .leading)
                        
                        Rectangle()
                            .fill(Color.purple.opacity(0.7))
                            .frame(width: CGFloat(data.efficiency * 100), height: 16)
                            .cornerRadius(8)
                        
                        Text("\(Int(data.efficiency * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("データが不足しています")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("もう少しタスクを記録してから、分析データをご確認ください")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func loadAnalyticsData() {
        // 実際のアプリではCore Dataから取得
        analyticsData = generateSampleData()
    }
    
    private func generateSampleData() -> [AnalyticsData] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            
            return AnalyticsData(
                date: date,
                plannedHours: Double.random(in: 4...8),
                actualHours: Double.random(in: 3...9),
                efficiency: Double.random(in: 0.6...1.2)
            )
        }
    }
    
    private func calculateAchievementRate() -> Int {
        let totalPlanned = analyticsData.map(\.plannedHours).reduce(0, +)
        let totalActual = analyticsData.map(\.actualHours).reduce(0, +)
        
        guard totalPlanned > 0 else { return 0 }
        return min(100, Int((totalActual / totalPlanned) * 100))
    }
    
    private func calculateEfficiencyScore() -> Int {
        let averageEfficiency = analyticsData.map(\.efficiency).reduce(0, +) / Double(analyticsData.count)
        return Int(averageEfficiency * 100)
    }
    
    private func getCategoryHours(_ category: TaskCategory) -> Double {
        // 実際のアプリではCore Dataから取得
        return Double.random(in: 1...5)
    }
    
    private func formatHours(_ hours: Double) -> String {
        return String(format: "%.1fh", hours)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AnalyticsData {
    let date: Date
    let plannedHours: Double
    let actualHours: Double
    let efficiency: Double
}

enum AnalyticsPeriod: CaseIterable {
    case week
    case month
    case quarter
    
    var displayName: String {
        switch self {
        case .week: return "週"
        case .month: return "月"
        case .quarter: return "四半期"
        }
    }
}
