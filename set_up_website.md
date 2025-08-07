# GitHub Pages 網站部署流程

## 📋 前置要求
- GitHub 帳號
- Git 已安裝
- Flutter 開發環境已設定

## 🚀 部署流程

### 步驟 1：建立 GitHub Repository

1. 登入 GitHub 網站 (https://github.com)
2. 點擊右上角的 `+` 按鈕，選擇 `New repository`
3. 填寫 Repository 資訊：
   - **Repository name**: `capacity-calculator` (或您喜歡的名稱)
   - **Description**: `建議使用容量計算器 - Flutter Web App`
   - **Public** (必須選擇 Public 才能使用免費的 GitHub Pages)
   - 勾選 `Add a README file`
4. 點擊 `Create repository`

### 步驟 2：將本地專案推送到 GitHub

```bash
# 在專案根目錄初始化 Git repository
git init

# 添加遠端 repository (替換成您的 GitHub 用戶名)
git remote add origin https://github.com/您的用戶名/capacity-calculator.git

# 添加所有檔案
git add .

# 建立第一次提交
git commit -m "Initial commit: Flutter web capacity calculator

🎯 Features:
- Voice codec format selection (G.729/G.711)
- Storage size configuration (32GB standard/custom)
- PBX specification selection
- Company type and usage parameters input
- Real-time calculation and results display
- Background calculation process display

🎨 UI Features:
- Compact responsive design
- Color-coded sections for better UX
- Form validation and error handling

🤖 Generated with Claude Code"

# 推送到 GitHub
git push -u origin main
```

### 步驟 3：編譯 Flutter Web 應用程式

```bash
# 編譯為 web 版本
flutter build web --release

# 檢查編譯結果
ls build/web/
```

### 步驟 4：設定 GitHub Pages

#### 方法A：使用 GitHub Actions (推薦)

1. 在專案根目錄建立 `.github/workflows` 資料夾：
```bash
mkdir -p .github/workflows
```

2. 建立 `.github/workflows/deploy.yml` 檔案：
```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
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
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

3. 提交並推送 GitHub Actions 設定：
```bash
git add .github/
git commit -m "Add GitHub Actions workflow for automatic deployment"
git push origin main
```

#### 方法B：手動部署

1. 建立 `gh-pages` 分支：
```bash
git checkout -b gh-pages
```

2. 清空分支內容並複製 build 檔案：
```bash
# 清空除了 .git 以外的所有檔案
git rm -rf .
git clean -fxd

# 複製 build/web 內容到根目錄
cp -r build/web/* .
cp -r build/web/.* . 2>/dev/null || true

# 建立 .nojekyll 檔案 (重要)
touch .nojekyll
```

3. 提交並推送：
```bash
git add .
git commit -m "Deploy Flutter web app to GitHub Pages"
git push origin gh-pages
```

### 步驟 5：啟用 GitHub Pages

1. 到您的 GitHub Repository 頁面
2. 點擊 `Settings` 頁籤
3. 在左側選單中找到 `Pages`
4. 在 `Source` 部分：
   - **方法A用戶**: 選擇 `Deploy from a branch`，選擇 `gh-pages` 分支，資料夾選擇 `/ (root)`
   - **方法B用戶**: 選擇 `GitHub Actions`
5. 點擊 `Save`

### 步驟 6：存取網站

1. GitHub 會需要幾分鐘時間來建置網站
2. 建置完成後，您可以在以下網址存取您的網站：
   ```
   https://您的用戶名.github.io/capacity-calculator/
   ```
3. 在 Repository 的 `Settings > Pages` 頁面也會顯示網站網址

## 🔄 更新網站

### 使用 GitHub Actions (方法A)
只需要將程式碼推送到 main 分支，GitHub Actions 會自動重新建置和部署：
```bash
git add .
git commit -m "Update: 修改描述"
git push origin main
```

### 手動更新 (方法B)
1. 在 main 分支進行修改
2. 重新編譯：`flutter build web --release`
3. 切換到 gh-pages 分支並重複步驟4的手動部署流程

## ⚠️ 注意事項

1. **Repository 必須是 Public** 才能使用免費的 GitHub Pages
2. **base-href 設定很重要**，確保在編譯時設定正確的基礎路徑
3. **建立 .nojekyll 檔案** 避免 Jekyll 處理造成的問題
4. GitHub Pages 有流量和容量限制，但對於一般使用足夠
5. 網站更新可能需要幾分鐘時間生效

## 🛠️ 疑難排解

### 問題1：網站顯示空白頁面
- 檢查是否正確設定了 `--base-href` 參數
- 確保 `.nojekyll` 檔案存在

### 問題2：GitHub Actions 失敗
- 檢查 Flutter 版本是否正確
- 查看 Actions 頁面的錯誤訊息

### 問題3：CSS/JS 檔案載入失敗
- 檢查 base-href 設定是否與 repository 名稱一致
- 確保所有檔案都已正確提交到 gh-pages 分支

## ⚠️ 常見問題修正

### 問題1: 網站顯示空白頁面
**原因**: `base href` 設定錯誤
**解決方案**:
```bash
# 編譯時必須指定正確的 base-href
flutter build web --release --base-href="/repository-名稱/"

# 例如：
flutter build web --release --base-href="/capacity-calculator/"
```

**手動修正**:
如果已經部署但發現空白，可以在 gh-pages 分支中手動修改 `index.html`:
```html
<!-- 錯誤 -->
<base href="/">

<!-- 正確 -->
<base href="/capacity-calculator/">
```

### 問題2: CSS/JS 檔案載入失敗
**原因**: 路徑錯誤，通常也是 base-href 問題
**解決方案**: 同問題1的解決方案

### 問題3: GitHub Pages 沒有更新
**原因**: GitHub Pages 有快取機制
**解決方案**:
1. 等待 5-10 分鐘
2. 強制重新整理頁面 (Ctrl+F5 或 Cmd+Shift+R)
3. 清除瀏覽器快取

## 📞 完成！

完成以上步驟後，您的 Flutter Web 容量計算器就會在 GitHub Pages 上線，任何人都可以透過網址存取使用！

**實際部署網址**: https://yyuchen-workspace.github.io/capacity-calculator/