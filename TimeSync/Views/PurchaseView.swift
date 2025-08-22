import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    @State private var isPurchasing = false
    
    let onPurchaseComplete: (Bool) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    pricingSection
                    testimonialsSection
                }
                .padding()
            }
            .navigationTitle("Pro版にアップグレード")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("復元") {
                        restorePurchases()
                    }
                    .font(.body)
                }
            }
        }
        .onAppear {
            storeManager.loadProducts()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("TimeSync Pro")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("さらに詳細な時間管理で\n生産性を向上させましょう")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("Pro版の特典")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                FeatureCard(
                    icon: "chart.bar.fill",
                    title: "詳細分析",
                    description: "週次・月次レポートで時間の使い方を把握"
                )
                
                FeatureCard(
                    icon: "square.and.arrow.up.fill",
                    title: "データエクスポート",
                    description: "CSV形式でデータを出力・共有"
                )
                
                FeatureCard(
                    icon: "paintbrush.fill",
                    title: "カスタマイズ",
                    description: "テーマやアイコンを自分好みに変更"
                )
                
                FeatureCard(
                    icon: "clock.arrow.2.circlepath",
                    title: "無制限履歴",
                    description: "過去のすべてのデータを永続保存"
                )
                
                FeatureCard(
                    icon: "app.badge.checkmark.fill",
                    title: "高度なウィジェット",
                    description: "中・大サイズウィジェットが利用可能"
                )
                
                FeatureCard(
                    icon: "bell.badge.fill",
                    title: "スマート通知",
                    description: "AIによる効率的な通知タイミング"
                )
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            Text("料金プラン")
                .font(.title2)
                .fontWeight(.semibold)
            
            PricingCard(
                title: "Pro版",
                price: "¥480",
                period: "/ 月",
                features: [
                    "すべてのPro機能",
                    "無制限データ保存",
                    "優先サポート",
                    "定期的な新機能追加"
                ],
                isPopular: true
            )
            
            Button(action: purchasePro) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("今すぐ購入")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isPurchasing ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isPurchasing)
            
            Text("7日間の無料トライアル付き")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var testimonialsSection: some View {
        VStack(spacing: 16) {
            Text("ユーザーの声")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                TestimonialCard(
                    text: "時間の使い方が可視化されて、無駄な時間が大幅に減りました！",
                    author: "A.Tさん",
                    role: "フリーランサー"
                )
                
                TestimonialCard(
                    text: "予定と実際の差を把握することで、より正確な見積もりができるようになりました。",
                    author: "M.Kさん",
                    role: "プロジェクトマネージャー"
                )
            }
        }
    }
    
    private func purchasePro() {
        isPurchasing = true
        
        Task {
            let success = await storeManager.purchaseProduct()
            
            await MainActor.run {
                isPurchasing = false
                
                if success {
                    UserDefaults.standard.set(true, forKey: "isPro")
                    onPurchaseComplete(true)
                    dismiss()
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            await storeManager.restorePurchases()
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    let features: [String]
    let isPopular: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            if isPopular {
                Text("人気プラン")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(price)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(period)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                        Text(feature)
                            .font(.body)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct TestimonialCard: View {
    let text: String
    let author: String
    let role: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\"\(text)\"")
                .font(.body)
                .italic()
            
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(author)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(role)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    private init() {}
    
    func loadProducts() {
        // StoreKitの製品を読み込み
        print("製品を読み込み中...")
    }
    
    func purchaseProduct() async -> Bool {
        // 実際の購入処理
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒待機（デモ用）
        return true
    }
    
    func restorePurchases() async {
        // 購入を復元
        print("購入を復元中...")
    }
}