# GitHub上傳流程與部署設定

## 專案概述
這是一個基於 Flutter 的 IP PBX 錄音容量計算器網頁應用程式，使用 GitHub Actions 自動部署到 GitHub Pages。

## GitHub Actions 自動部署設定

### 1. 檔案結構
```
.github/
  workflows/
    deploy.yml    # 部署工作流程設定檔
```

### 2. 部署工作流程設定 (.github/workflows/deploy.yml)
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

## 開發與上傳流程

### 1. 本地開發測試
```bash
# 安裝依賴
flutter pub get

# 本地測試運行
flutter run -d chrome

# 建置網頁版本
flutter build web
```

### 2. 程式碼提交與推送
```bash
# 檢查 git 狀態
git status

# 添加修改的檔案
git add lib/main.dart build/

# 創建提交
git commit -m "描述修改內容

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 推送到 GitHub
git push origin main
```

### 3. 自動部署流程
1. **觸發條件**: 推送到 `main` 分支時自動觸發
2. **環境設置**: Ubuntu 最新版本，Flutter 3.32.7 穩定版
3. **建置過程**: 
   - 檢出程式碼
   - 設定 Flutter 環境
   - 安裝依賴套件
   - 建置 Web 版本
4. **部署過程**:
   - 設定 GitHub Pages
   - 上傳建置產物
   - 部署到 GitHub Pages

### 4. GitHub Pages 設定
1. 進入 Repository Settings
2. 找到 Pages 設定
3. Source 選擇 "GitHub Actions"
4. 確認部署完成後可透過 URL 存取

## 部署後存取
- **網站 URL**: `https://yyuchen-workspace.github.io/capacity-calculator/`
- **自動更新**: 每次推送到 main 分支都會自動重新部署

## GitHub Actions 權限設定

### 必需的權限設定
1. **進入 Repository Settings**
2. **Actions → General**
3. **Workflow permissions** 設定為:
   - ✅ "Read and write permissions"
   - ✅ "Allow GitHub Actions to create and approve pull requests"

### GitHub Pages 設定
1. **Settings → Pages**
2. **Source** 選擇: "GitHub Actions"

## 監控部署狀態
- **Actions 頁面**: 查看工作流程執行狀態
  - 🟢 綠色: 部署成功
  - 🔴 紅色: 部署失敗
  - 🟡 黃色: 執行中

## 故障排除

### 常見問題與解決方案

#### 1. 權限錯誤 (403 Permission denied)
- 檢查 Actions 權限設定
- 確認選擇 "Read and write permissions"

#### 2. 建置失敗
```bash
# 本地測試建置
flutter build web --release

# 檢查依賴
flutter pub get
flutter doctor
```

#### 3. 部署失敗
- 確認 GitHub Pages 設定為 "GitHub Actions"
- 檢查 base-href 設定是否正確
- 查看 Actions 日誌詳細錯誤

#### 4. 網站 404 錯誤
- 檢查 Repository 名稱與 base-href 是否一致
- 確認 build/web 目錄內容正確

## 開發最佳實踐

### 1. 提交前檢查
```bash
# 本地測試
flutter run -d chrome

# 建置測試
flutter build web

# 檢查語法
flutter analyze
```

### 2. 提交訊息格式
```bash
# 功能更新
git commit -m "Update UI layout and button positioning

- Increase button spacing to 45px
- Improve purple card height and content centering
- Add responsive design for mobile and desktop

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 3. 分支管理
```bash
# 功能開發分支
git checkout -b feature/ui-improvements

# 完成後合併
git checkout main
git merge feature/ui-improvements
```

## 版本發布

### 創建版本標籤
```bash
# 創建標籤
git tag -a v1.0.0 -m "Release v1.0.0: Initial complete version"

# 推送標籤
git push origin v1.0.0
```

## 注意事項
1. **base-href 設定**: 必須與 Repository 名稱一致
2. **Flutter 版本**: 建議與本地開發環境版本一致
3. **權限設定**: 確保 workflow 有正確的權限
4. **分支保護**: 只有 main 分支推送會觸發部署
5. **建置快取**: Actions 會自動快取 Flutter 和依賴套件