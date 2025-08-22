# TimeSync - 予実管理アプリ

SwiftUIで実装されたiOS向けの時間管理アプリです。

## 機能

### ✅ 実装済み機能

- **メイン画面**: 予定と実際の左右分割レイアウト
- **タスク入力**: タイマー機能付きの入力画面
- **カテゴリ管理**: 仕事📝、休憩☕、移動🚶、その他📋
- **ウィジェット**: 小・中サイズ対応
- **通知機能**: 定期リマインダー・スマート通知
- **データ永続化**: Core Data実装
- **設定画面**: 通知間隔設定、Pro版管理
- **Pro版機能**: 詳細分析、データエクスポート、カスタマイズ
- **課金システム**: StoreKit実装（Pro版月額¥480）

### 📱 対応機能

1. **基本機能**
   - タスクの予定時間・実際時間記録
   - 超過時間の警告表示
   - カテゴリ別アイコン・色分け

2. **ウィジェット**
   - 小サイズ: クイック記録ボタン
   - 中サイズ: カテゴリ別進捗表示

3. **通知**
   - 定期リマインダー（15分〜2時間）
   - タスク時間到達通知
   - 超過時間警告

4. **Pro版限定**
   - 週次・月次分析レポート
   - CSVデータエクスポート
   - テーマ・アイコンカスタマイズ
   - 無制限データ保存

## プロジェクト構造

```
TimeSync/
├── TimeSyncApp.swift          # アプリエントリーポイント
├── ContentView.swift          # ナビゲーション構造
├── Views/                     # UI関連
│   ├── MainView.swift         # メイン画面（予定/実際表示）
│   ├── AddEntryView.swift     # タスク入力画面
│   ├── TimeEntryRow.swift     # タスク行表示
│   ├── SettingsView.swift     # 設定画面
│   ├── AnalyticsView.swift    # 分析画面（Pro版）
│   └── PurchaseView.swift     # 課金画面
├── Models/                    # データモデル
│   ├── TimeEntry.swift        # タスクデータ構造
│   ├── TaskCategory.swift     # カテゴリ定義
│   └── TimeSync.xcdatamodeld  # Core Dataモデル
├── Services/                  # サービス層
│   ├── PersistenceController.swift  # Core Data管理
│   └── NotificationManager.swift    # 通知管理
└── TimeSyncWidget/           # ウィジェット拡張
    ├── TimeSyncWidget.swift
    └── TimeSyncWidgetBundle.swift
```

## ビルド方法

1. Xcodeでプロジェクト（`.xcodeproj`）を開く
2. ターゲットデバイス（シミュレーター or 実機）を選択
3. ⌘+R でビルド・実行

## 必要な権限

- **通知**: リマインダー機能のため
- **ウィジェット**: ホーム画面ウィジェット表示

## App Store申請準備

- [x] コード実装完了
- [ ] アイコン・スクリーンショット作成
- [ ] プライバシーポリシー・利用規約作成
- [ ] App Store Connect設定

## 今後の拡張予定

- Apple Watch対応
- Googleカレンダー連携
- Siri Shortcuts対応
- AI予測機能