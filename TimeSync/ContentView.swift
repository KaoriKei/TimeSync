import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                MainView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("今日")
            }
            .tag(0)
            
            NavigationView {
                AddEntryView { newEntry in
                    // Handle new entry
                }
            }
            .tabItem {
                Image(systemName: "plus")
                Text("タスク追加")
            }
            .tag(1)
            
            NavigationView {
                AnalyticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("分析")
            }
            .tag(2)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("設定")
            }
            .tag(3)
        }
    }
}