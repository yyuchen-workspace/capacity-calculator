# GitHub 上傳流程說明文檔

本文檔詳細說明如何將 IP PBX 建議錄音天數計算器專案上傳至 GitHub 並進行版本管理。

## 專案簡介

**專案名稱:** IP PBX 建議錄音天數計算器  
**技術棧:** Flutter Web (Dart)  
**功能:** 基於用戶輸入的語音編碼格式、硬碟大小、PBX規格等參數，計算建議的錄音天數和硬碟容量  
**特色:** 響應式設計，支援手機版和電腦版不同佈局  

## 目錄結構
```
capacity_calculater/
├── lib/
│   └── main.dart           # 主要應用程式碼
├── web/                    # Web 平台配置文件
├── build/web/              # 編譯後的 Web 文件（靜態網站）
├── pubspec.yaml           # Flutter 依賴管理文件
├── CLAUDE.md              # 專案需求和開發指南
├── README.md              # 專案說明文檔
└── GitHub上傳流程.md      # 本文檔
```

## GitHub 上傳步驟

### 1. 初始化 Git 倉庫（如果是新專案）
```bash
# 進入專案目錄
cd capacity_calculater

# 初始化 Git
git init

# 添加所有文件
git add .

# 創建初始提交
git commit -m "Initial commit: Flutter web capacity calculator"
```

### 2. 在 GitHub 創建遠程倉庫
1. 登入 GitHub 帳號
2. 點擊右上角 "+" 按鈕，選擇 "New repository"
3. 輸入倉庫名稱：`capacity-calculator`
4. 選擇 Public 或 Private
5. 不勾選 "Initialize this repository with a README"
6. 點擊 "Create repository"

### 3. 連接本地倉庫與 GitHub
```bash
# 添加遠程倉庫
git remote add origin https://github.com/YOUR_USERNAME/capacity-calculator.git

# 推送代碼到 GitHub
git push -u origin main
```

### 4. 日常版本管理流程

#### 4.1 提交代碼變更
```bash
# 查看修改狀態
git status

# 添加修改的文件
git add lib/main.dart

# 或者添加所有修改
git add .

# 提交變更（建議使用描述性提交訊息）
git commit -m "功能：新增響應式設計支援手機版和電腦版佈局"

# 推送到 GitHub
git push
```

#### 4.2 推薦的提交訊息格式
```bash
# 新功能
git commit -m "功能：新增計算背景過程顯示功能"

# Bug 修復
git commit -m "修復：修正電腦版單位顯示問題"

# UI 改進
git commit -m "UI：優化手機版欄位間距和按鈕位置"

# 重構
git commit -m "重構：提取響應式設計通用方法"
```

## 自動部署到 GitHub Pages

### 5. GitHub Actions 自動部署詳解
本專案使用現代化的 GitHub Actions 自動部署流程，採用官方 GitHub Pages Actions 進行部署。

#### 5.1 工作流程配置檔案
**位置**: `.github/workflows/deploy.yml`

**完整配置內容**:
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

#### 5.2 部署觸發條件與權限
**觸發條件**：
- 推送代碼到 `main` 分支時自動觸發並部署
- Pull Request 到 `main` 分支時會執行建置測試（但不部署）

**權限設置**：
- `contents: read` - 讀取儲存庫內容
- `pages: write` - 寫入 GitHub Pages
- `id-token: write` - 寫入身份令牌（用於安全驗證）

#### 5.3 自動部署步驟詳解
1. **代碼檢出**: 使用 `actions/checkout@v3` 取得最新代碼
2. **環境設置**: 安裝 Flutter 3.32.7 穩定版
3. **依賴安裝**: 執行 `flutter pub get` 安裝專案依賴
4. **Web 編譯**: 執行 `flutter build web --release` 編譯生產版本
5. **Pages 配置**: 使用 `actions/configure-pages@v4` 配置 GitHub Pages
6. **上傳產物**: 使用 `actions/upload-pages-artifact@v3` 上傳建置結果
7. **執行部署**: 使用 `actions/deploy-pages@v4` 部署到 GitHub Pages

#### 5.4 必需的 GitHub 設置

**Step 1: 設置 Actions 權限**
1. 進入 GitHub 儲存庫頁面
2. 點擊 "**Settings**" 標籤
3. 點擊左側選單的 "**Actions**" → "**General**"
4. 在 "**Workflow permissions**" 選擇：
   - ✅ **"Read and write permissions"**
5. 勾選：
   - ✅ **"Allow GitHub Actions to create and approve pull requests"**
6. 點擊 "**Save**" 儲存設定

**Step 2: 啟用 GitHub Pages**
1. 在同一個 Settings 頁面中
2. 點擊左側選單的 "**Pages**"
3. 在 "**Source**" 下拉選單中選擇：
   - ✅ **"GitHub Actions"**
4. 設定會自動儲存

#### 5.5 部署完成後的訪問
- **主要網址**: `https://yyuchen-workspace.github.io/capacity-calculator/`
- 每次推送到 `main` 分支後，約需要 2-5 分鐘完成自動部署
- 部署完成後網站內容會自動更新

#### 5.6 監控部署狀態
- 進入儲存庫的 "**Actions**" 標籤
- 查看最近的工作流程執行狀態：
  - 🟢 **綠色勾選**: 部署成功
  - 🔴 **紅色叉號**: 部署失敗（點擊可查看詳細錯誤日誌）
  - 🟡 **黃色圓圈**: 正在執行中

#### 5.7 部署失敗排解
**常見錯誤及解決方法**：

1. **403 Permission denied 錯誤**
   - 確認 Actions 權限設置是否正確
   - 檢查是否選擇 "Read and write permissions"

2. **Flutter 建置失敗**
   - 在本地測試 `flutter build web --release` 是否正常
   - 檢查 pubspec.yaml 依賴是否有問題

3. **Pages 部署失敗** 
   - 確認 GitHub Pages 設置為 "GitHub Actions"
   - 查看 Actions 日誌中的詳細錯誤訊息

4. **網站訪問 404**
   - 檢查 base-href 設置是否正確
   - 確認儲存庫名稱與網址路徑一致

## 開發工作流程

### 6. 本地開發和測試
```bash
# 安裝依賴
flutter pub get

# 本地運行（開發模式）
flutter run -d chrome

# 編譯 Web 版本
flutter build web

# 預覽編譯後的 Web 版本
cd build/web
python -m http.server 8080
# 然後在瀏覽器訪問 http://localhost:8080
```

### 7. 響應式設計測試
- **電腦版測試：** 瀏覽器寬度 > 800px
- **手機版測試：** 瀏覽器寬度 ≤ 800px
- **建議使用 Chrome 開發者工具進行多設備測試**

## 版本管理策略

### 8. 分支管理建議
```bash
# 主分支（穩定版本）
main

# 開發新功能時創建分支
git checkout -b feature/new-calculation-logic
# 開發完成後合併
git checkout main
git merge feature/new-calculation-logic

# 熱修復分支
git checkout -b hotfix/fix-unit-display
```

### 9. 標籤管理（版本發布）
```bash
# 創建版本標籤
git tag -a v1.0.0 -m "版本 1.0.0：初版發布，包含完整計算功能和響應式設計"

# 推送標籤到 GitHub
git push origin v1.0.0

# 查看所有標籤
git tag -l
```

## 故障排除

### 10. 常見問題解決

#### 10.1 推送被拒絕
```bash
# 如果遠程有更新，先拉取再推送
git pull origin main
git push
```

#### 10.2 合併衝突
```bash
# 解決衝突後
git add .
git commit -m "解決合併衝突"
git push
```

#### 10.3 GitHub Pages 部署失敗
**常見錯誤：Permission denied (403)**
1. 檢查 Actions 權限設定：
   - Settings → Actions → General → Workflow permissions
   - 選擇 "Read and write permissions"
   - 勾選 "Allow GitHub Actions to create and approve pull requests"

2. 檢查 Pages 設定：
   - Settings → Pages → Source: "GitHub Actions"

3. 其他檢查項目：
   - 確認 `flutter build web` 命令可在本地成功執行
   - 檢查 `.github/workflows/deploy.yml` 配置是否正確
   - 查看 Actions 標籤中的詳細部署日誌

## 專案維護

### 11. 定期維護建議
- **每月更新 Flutter 依賴：** `flutter pub upgrade`
- **定期備份重要分支**
- **保持提交歷史清晰**
- **定期清理無用分支**

### 12. 協作開發
如需多人協作開發：
1. 設置分支保護規則
2. 要求 Pull Request 審查
3. 使用 Issues 追蹤功能需求和 Bug
4. 建立 Code Review 流程

## 總結

本文檔涵蓋了從初始上傳到日常維護的完整 GitHub 工作流程。遵循這些步驟可以確保專案代碼的安全管理和持續部署。

**重要提醒：**
- 定期提交代碼，避免丟失工作
- 使用描述性的提交訊息
- 在推送前測試功能是否正常
- 保持代碼庫的整潔和組織性

---
*文檔創建時間：2025-08-08*  
*最後更新：2025-08-08*