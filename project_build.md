# 專案建置與開發指南

## 專案概述
**專案名稱**: IP PBX 建議錄音天數計算器  
**技術棧**: Flutter Web (Dart)  
**部署平台**: GitHub Pages (自動部署)  
**開發環境**: Flutter 3.32.7 穩定版  

## 必要檔案結構

### 核心檔案架構
```
capacity_calculater/
├── lib/
│   └── main.dart                    # 主應用程式碼 (Flutter/Dart)
├── web/
│   ├── index.html                   # HTML 模板檔案
│   └── manifest.json                # PWA 配置檔案
├── build/web/                       # 編譯輸出目錄 (自動生成)
│   ├── index.html                   # 編譯後的主頁面
│   ├── main.dart.js                 # 編譯後的 JavaScript
│   ├── flutter.js                   # Flutter 引擎
│   └── assets/                      # 靜態資源
├── .github/
│   └── workflows/
│       └── deploy.yml               # GitHub Actions 部署設定
├── pubspec.yaml                     # Flutter 專案配置與依賴管理
├── pubspec.lock                     # 依賴版本鎖定檔案
├── CLAUDE.md                        # 專案需求與開發指南
├── GitHub上傳流程.md                # 部署流程說明
├── project_build.md                 # 本文檔
└── README.md                        # 專案說明文檔
```

### 重要配置檔案

#### 1. pubspec.yaml (Flutter 專案配置)
```yaml
name: web_calculator_app
description: IP PBX 建議錄音天數計算器
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=2.18.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

#### 2. web/index.html (HTML 模板)
```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="IP PBX建議錄音天數計算器">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="建議使用容量計算器">
  <title>建議使用容量計算器</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter.js" defer></script>
</body>
</html>
```

#### 3. .github/workflows/deploy.yml (自動部署)
```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.7'
        channel: 'stable'
        
    - name: Get dependencies
      run: flutter pub get
      
    - name: Build web
      run: flutter build web --release --base-href="/capacity-calculator/"
      
    - name: Setup Pages
      uses: actions/configure-pages@v4
      
    - name: Upload artifact
      uses: actions/upload-pages-artifact@v3
      with:
        path: './build/web'
        
    - name: Deploy to GitHub Pages
      id: deployment
      uses: actions/deploy-pages@v4
      if: github.ref == 'refs/heads/main'
```

## 完整專案建置步驟

### 第一階段：環境準備

#### 1. 安裝 Flutter 開發環境
```bash
# 下載並安裝 Flutter SDK 3.32.7
# https://flutter.dev/docs/get-started/install

# 驗證安裝
flutter doctor

# 確認 web 支援已啟用
flutter config --enable-web
```

#### 2. 建立專案目錄
```bash
# 建立專案
flutter create capacity_calculater
cd capacity_calculater

# 或從現有專案開始
git clone <repository-url>
cd capacity_calculater
```

### 第二階段：核心開發

#### 3. 主程式開發 (lib/main.dart)
**重要功能模組**:
- 響應式設計 (手機版 ≤800px，電腦版 >800px)
- 輸入驗證與錯誤處理
- 計算邏輯實現
- UI 組件與布局管理

**核心計算公式**:
```dart
// 實際可用容量
double actualUsableCapacity = storageSize * 0.8;

// 實際錄音可用容量
double actualRecordingCapacity = actualUsableCapacity - 1 - pbxDataArea;

// 每月通話秒數
int monthlyCallSeconds = dailySeconds * phoneCount * recordDays;

// 錄音佔用容量
double recordingCapacity = (monthlyCallSeconds * bytesPerSecond / 1048576 / 1024 * 1.5);

// 建議硬碟容量 (依規格表對應)
```

#### 4. UI 佈局實現
**響應式設計要點**:
- 手機版: 垂直單欄布局
- 電腦版: 左右雙欄布局 (輸入區 + 結果區)
- 卡片式設計: 不同顏色區分功能區塊
- 按鈕位置: 紫色卡片下方 45px 間距

### 第三階段：測試與驗證

#### 5. 本地開發測試
```bash
# 安裝依賴
flutter pub get

# 本地運行測試
flutter run -d chrome

# 檢查程式碼品質
flutter analyze

# 執行單元測試 (如有)
flutter test
```

#### 6. 建置測試
```bash
# 建置 Web 版本
flutter build web --release

# 本地預覽建置結果
cd build/web
python -m http.server 8080
# 瀏覽器訪問 http://localhost:8080
```

#### 7. 功能測試檢查表
**基本功能測試**:
- [ ] 語音編碼格式選擇 (G.729/G.711)
- [ ] 硬碟大小設定 (標準版/自訂)
- [ ] PBX 規格選擇 (5種規格)
- [ ] 公司類型選擇 (一般/電訪企業)
- [ ] 話機數量輸入與驗證
- [ ] 錄音天數輸入與驗證 (≤365天)

**計算功能測試**:
- [ ] 實際可用容量計算
- [ ] 每月通話秒數計算與格式化
- [ ] 錄音佔用容量計算與進位
- [ ] 建議硬碟容量規格對應
- [ ] R6 備份系統建議 (>365天)

**UI 響應式測試**:
- [ ] 手機版布局 (寬度 ≤800px)
- [ ] 電腦版布局 (寬度 >800px)
- [ ] 各區塊顏色與間距
- [ ] 按鈕位置與功能

**錯誤處理測試**:
- [ ] 必填欄位驗證
- [ ] 數字格式驗證
- [ ] 負數輸入檢查
- [ ] 超出範圍值檢查
- [ ] 錯誤訊息彈窗顯示

### 第四階段：部署設定

#### 8. GitHub Repository 設定
```bash
# 初始化 Git
git init
git add .
git commit -m "Initial commit: Flutter web capacity calculator"

# 連接 GitHub
git remote add origin https://github.com/yyuchen-workspace/capacity-calculator.git
git push -u origin main
```

#### 9. GitHub Actions 設定
**必要設定步驟**:
1. **Repository Settings**:
   - Actions → General → Workflow permissions
   - 選擇: "Read and write permissions"
   - 勾選: "Allow GitHub Actions to create and approve pull requests"

2. **GitHub Pages 設定**:
   - Settings → Pages → Source
   - 選擇: "GitHub Actions"

#### 10. 自動部署驗證
```bash
# 推送程式碼觸發部署
git add .
git commit -m "Deploy to GitHub Pages"
git push origin main

# 監控部署狀態
# GitHub → Actions 頁面查看工作流程狀態
```

### 第五階段：品質保證

#### 11. 部署後測試
**線上功能驗證**:
- [ ] 網站可正常訪問
- [ ] 所有功能正常運作
- [ ] 響應式設計正確顯示
- [ ] 計算結果準確性
- [ ] 錯誤處理正常

**效能測試**:
- [ ] 頁面載入速度
- [ ] 互動響應時間
- [ ] 記憶體使用情況
- [ ] 不同瀏覽器相容性

#### 12. 跨平台測試
**瀏覽器測試**:
- [ ] Chrome (推薦)
- [ ] Firefox
- [ ] Safari
- [ ] Edge

**設備測試**:
- [ ] 桌面電腦 (>800px 寬度)
- [ ] 平板電腦 (中等寬度)
- [ ] 手機 (≤800px 寬度)

## 持續維護流程

### 日常開發工作流程
```bash
# 1. 創建功能分支
git checkout -b feature/new-feature

# 2. 開發與測試
flutter run -d chrome
flutter test
flutter build web

# 3. 提交變更
git add .
git commit -m "Add new feature: description"

# 4. 合併到主分支
git checkout main
git merge feature/new-feature

# 5. 推送並自動部署
git push origin main
```

### 版本管理
```bash
# 創建版本標籤
git tag -a v1.1.0 -m "Release v1.1.0: Feature updates"
git push origin v1.1.0

# 查看版本歷史
git tag -l
```

### 問題排除檢查清單

#### 建置失敗排除
- [ ] `flutter doctor` 檢查環境
- [ ] `flutter clean && flutter pub get` 清理重建
- [ ] 檢查 pubspec.yaml 語法
- [ ] 驗證 Dart 程式碼語法

#### 部署失敗排除
- [ ] 檢查 GitHub Actions 權限
- [ ] 確認 .github/workflows/deploy.yml 設定
- [ ] 查看 Actions 頁面錯誤日誌
- [ ] 驗證 base-href 設定正確

#### 功能問題排除
- [ ] 本地測試重現問題
- [ ] 檢查瀏覽器控制台錯誤
- [ ] 驗證計算邏輯正確性
- [ ] 確認輸入驗證規則

## 專案維護建議

### 定期維護任務
- **每月**: 更新 Flutter 依賴 (`flutter pub upgrade`)
- **每季**: 檢查 GitHub Actions 版本更新
- **每半年**: 評估 Flutter SDK 升級
- **持續**: 監控 GitHub Pages 部署狀態

### 程式碼品質維護
- 遵循 Dart 編碼規範
- 保持提交訊息清晰
- 定期重構重複程式碼
- 維護文檔同步更新

### 效能最佳化
- 定期檢查建置檔案大小
- 最佳化圖片與資源載入
- 監控頁面載入效能
- 實施必要的快取策略

---

**文檔版本**: v1.0  
**最後更新**: 2025-08-12  
**維護者**: Claude Code Development Team