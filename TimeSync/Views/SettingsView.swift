import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var reminderInterval: ReminderInterval = .thirtyMinutes
    @State private var isProVersion = false
    @State private var showingPurchaseSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("通知設定") {
                    Picker("通知間隔", selection: $reminderInterval) {
                        ForEach(ReminderInterval.allCases, id: \.self) { interval in
                            Text(interval.displayName).tag(interval)
                        }
                    }
                    .onChange(of: reminderInterval) {
                        setupReminders()
                    }
                    
                    Button("通知のテスト") {
                        testNotification()
                    }
                }
                
                Section("カテゴリ管理") {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        HStack {
                            Text(category.icon)
                                .font(.title2)
                            Text(category.displayName)
                            Spacer()
                            Circle()
                                .fill(category.color)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                Section("Pro版") {
                    if isProVersion {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Pro版をご利用中")
                            Spacer()
                        }
                        
                        Button("データをエクスポート") {
                            exportData()
                        }
                        
                        NavigationLink("詳細分析", destination: AnalyticsView())
                        
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pro版の機能")
                                .font(.headline)
                            
                            FeatureRow(icon: "chart.bar", title: "詳細分析", description: "週次・月次レポート")
                            FeatureRow(icon: "square.and.arrow.up", title: "データエクスポート", description: "CSV形式で出力")
                            FeatureRow(icon: "paintbrush", title: "カスタマイズ", description: "テーマ・アイコン変更")
                            FeatureRow(icon: "clock.arrow.2.circlepath", title: "無制限履歴", description: "過去データ無制限保存")
                        }
                        
                        Button("Pro版にアップグレード（月額 ¥480）") {
                            showingPurchaseSheet = true
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                
                Section("アプリについて") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("フィードバックを送信") {
                        sendFeedback()
                    }
                    
                    Button("利用規約") {
                        openTerms()
                    }
                    
                    Button("プライバシーポリシー") {
                        openPrivacy()
                    }
                }
            }
            .navigationTitle("設定")
        }
        .sheet(isPresented: $showingPurchaseSheet) {
            PurchaseView(onPurchaseComplete: { success in
                if success {
                    isProVersion = true
                }
            })
        }
        .onAppear {
            checkProStatus()
            requestNotificationPermission()
        }
    }
    
    private func setupReminders() {
        notificationManager.cancelAllNotifications()
        notificationManager.scheduleRegularReminder(
            interval: reminderInterval.timeInterval,
            message: "今何してる？📝 予定と実際を記録しよう"
        )
    }
    
    private func testNotification() {
        notificationManager.scheduleRegularReminder(
            interval: 5,
            message: "テスト通知です 📱"
        )
    }
    
    private func requestNotificationPermission() {
        notificationManager.requestPermission()
        notificationManager.setupNotificationCategories()
    }
    
    private func checkProStatus() {
        // 実際のアプリではUserDefaultsやKeychain等で管理
        isProVersion = UserDefaults.standard.bool(forKey: "isPro")
    }
    
    private func exportData() {
        // CSV エクスポート機能（Pro版限定）
        print("データをエクスポート中...")
    }
    
    private func sendFeedback() {
        // フィードバック送信
        if let url = URL(string: "mailto:feedback@timesync.app") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTerms() {
        if let url = URL(string: "https://timesync.app/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPrivacy() {
        if let url = URL(string: "https://timesync.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

enum ReminderInterval: CaseIterable {
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case twoHours
    case custom
    
    var displayName: String {
        switch self {
        case .fifteenMinutes: return "15分"
        case .thirtyMinutes: return "30分"
        case .oneHour: return "1時間"
        case .twoHours: return "2時間"
        case .custom: return "カスタム"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .fifteenMinutes: return 15 * 60
        case .thirtyMinutes: return 30 * 60
        case .oneHour: return 60 * 60
        case .twoHours: return 2 * 60 * 60
        case .custom: return 30 * 60 // デフォルト値
        }
    }
}
