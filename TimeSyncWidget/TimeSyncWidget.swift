import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todayProgress: "3.5h記録済", categories: [
            CategoryData(category: .work, planned: 6*3600, actual: 5.5*3600),
            CategoryData(category: .break, planned: 1*3600, actual: 1.2*3600),
            CategoryData(category: .commute, planned: 2*3600, actual: 1.8*3600)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todayProgress: "3.5h記録済", categories: [
            CategoryData(category: .work, planned: 6*3600, actual: 5.5*3600),
            CategoryData(category: .break, planned: 1*3600, actual: 1.2*3600),
            CategoryData(category: .commute, planned: 2*3600, actual: 1.8*3600)
        ])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, todayProgress: "3.5h記録済", categories: [
            CategoryData(category: .work, planned: 6*3600, actual: 5.5*3600),
            CategoryData(category: .break, planned: 1*3600, actual: 1.2*3600),
            CategoryData(category: .commute, planned: 2*3600, actual: 1.8*3600)
        ])
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todayProgress: String
    let categories: [CategoryData]
}

struct CategoryData {
    let category: TaskCategory
    let planned: TimeInterval
    let actual: TimeInterval
    
    var plannedHours: String {
        let hours = planned / 3600
        return String(format: "%.1fh", hours)
    }
    
    var actualHours: String {
        let hours = actual / 3600
        return String(format: "%.1fh", hours)
    }
}

struct TimeSyncWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("📝")
                    .font(.title2)
                Text("今の行動記録")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Button(action: {}) {
                HStack {
                    Text("[タップして入力]")
                        .font(.body)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            HStack {
                Text("今日: \(entry.todayProgress)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(Array(entry.categories.prefix(3).enumerated()), id: \.offset) { index, categoryData in
                    VStack(spacing: 4) {
                        Text(categoryData.category.displayName)
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text(categoryData.category.icon)
                            .font(.title)
                        
                        VStack(spacing: 2) {
                            Text("予定: \(categoryData.plannedHours)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text("実際: \(categoryData.actualHours)")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    if index < 2 {
                        Divider()
                            .frame(width: 1)
                    }
                }
            }
            
            HStack {
                Text("今日の進捗: \(entry.todayProgress)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct TimeSyncWidget: Widget {
    let kind: String = "TimeSyncWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TimeSyncWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TimeSyncWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("TimeSync")
        .description("時間管理の進捗を確認できます")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    TimeSyncWidget()
} timeline: {
    SimpleEntry(date: .now, todayProgress: "3.5h記録済", categories: [
        CategoryData(category: .work, planned: 6*3600, actual: 5.5*3600),
        CategoryData(category: .break, planned: 1*3600, actual: 1.2*3600)
    ])
}

#Preview(as: .systemMedium) {
    TimeSyncWidget()
} timeline: {
    SimpleEntry(date: .now, todayProgress: "3.5h記録済", categories: [
        CategoryData(category: .work, planned: 6*3600, actual: 5.5*3600),
        CategoryData(category: .break, planned: 1*3600, actual: 1.2*3600),
        CategoryData(category: .commute, planned: 2*3600, actual: 1.8*3600)
    ])
}