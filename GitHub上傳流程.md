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

### 5. 設置 GitHub Actions 自動部署
專案已包含 `.github/workflows/deploy.yml` 配置文件，可自動將 Flutter Web 應用部署到 GitHub Pages。

#### 5.1 啟用 GitHub Pages
1. 進入 GitHub 倉庫頁面
2. 點擊 "Settings" 標籤
3. 滾動到 "Pages" 部分
4. 在 "Source" 下選擇 "GitHub Actions"

#### 5.2 自動部署流程
- 每次推送代碼到 `main` 分支時，GitHub Actions 會自動：
  1. 安裝 Flutter 環境
  2. 編譯 Web 應用
  3. 部署到 GitHub Pages
  
- 部署完成後，可通過以下網址訪問：
  `https://YOUR_USERNAME.github.io/capacity-calculator/`

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
1. 檢查 Actions 標籤中的部署日誌
2. 確認 `flutter build web` 命令可在本地成功執行
3. 檢查 `.github/workflows/deploy.yml` 配置是否正確

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