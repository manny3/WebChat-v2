# Android 快速開始指南

本指南提供最快速的方式來執行 Android app 開發。

## 🚀 快速啟動（推薦）

如果您已經完成環境設置，使用一鍵啟動腳本：

```bash
./scripts/start-android-dev.sh
```

這個腳本會自動完成：
1. ✅ 載入環境變數
2. ✅ 檢查開發環境
3. ✅ 檢查設備連接
4. ✅ 啟動 Metro Bundler（背景執行）
5. ✅ 編譯並安裝 Android App
6. ✅ 顯示詳細的執行狀態

---

## 📋 前置準備

### 首次使用必看

#### 1. 重新載入環境變數

我們已經更新了您的 `~/.zshrc` 檔案，請重新載入：

```bash
source ~/.zshrc
```

**或者關閉並重新開啟終端機。**

#### 2. 連接 Android 設備

**使用實體設備：**

1. 在 Android 設備上啟用開發者選項：
   - 設定 → 關於手機 → 連續點擊「版本號碼」7次
   
2. 啟用 USB 偵錯：
   - 設定 → 開發者選項 → 開啟「USB 偵錯」

3. 用 USB 線連接設備到電腦

4. 在設備上允許 USB 偵錯授權

5. 驗證連接：
   ```bash
   adb devices
   ```

**使用模擬器：**

```bash
# 列出可用的模擬器
emulator -list-avds

# 啟動模擬器（替換為您的模擬器名稱）
emulator -avd <模擬器名稱>
```

---

## 🛠️ 執行腳本說明

我們提供了三個腳本，根據您的需求選擇使用：

### 1. 環境檢查腳本

快速檢查您的開發環境是否正確設置：

```bash
./scripts/check-android-env.sh
```

**檢查項目：**
- ✅ JAVA_HOME 和 ANDROID_HOME 環境變數
- ✅ Java 版本
- ✅ adb 工具
- ✅ Android 設備連接狀態
- ✅ 專案依賴

**使用時機：**
- 首次設置後
- 遇到問題時
- 更換設備後

---

### 2. 快速執行腳本

提供彈性的執行選項：

```bash
./scripts/run-android.sh
```

**功能選單：**
1. 只啟動 Metro Bundler
2. 只編譯並運行 Android App
3. 啟動 Metro 並運行 Android App（推薦）
4. 檢查環境並退出

**使用時機：**
- 需要分開控制 Metro 和編譯流程
- Metro 已經在運行，只需重新編譯
- 想要更靈活的控制

---

### 3. 一鍵啟動腳本（最推薦）

完全自動化的開發環境啟動：

```bash
./scripts/start-android-dev.sh
```

**執行流程：**
1. 自動載入環境變數
2. 檢查 Java、adb、專案依賴
3. 檢查設備連接（無設備會提示）
4. 在背景啟動 Metro Bundler
5. 等待 Metro 就緒
6. 編譯並安裝 Android App
7. 提供 Metro 日誌選項

**使用時機：**
- 每天開始開發時
- 首次運行專案
- 最快速的啟動方式

---

## 📱 開發流程

### 標準開發流程

```bash
# 1. 確保環境變數已載入（只需執行一次）
source ~/.zshrc

# 2. 連接設備並驗證
adb devices

# 3. 啟動開發環境
./scripts/start-android-dev.sh

# 4. 開始開發！
#    修改 App.tsx 或其他檔案
#    應用會自動熱重載
```

### 熱重載

修改代碼後，React Native 會自動更新應用：

- **自動重載**：大多數修改會自動反映
- **手動重載**：在設備上按 R 鍵兩次
- **開發選單**：搖動設備或按 Cmd+M (Android)

### 停止開發

如果 Metro 在背景運行，停止方式：

```bash
# 方法 1: 使用腳本顯示的 PID
kill <PID>

# 方法 2: 找出並停止所有 Metro 進程
pkill -f "react-native.*start"

# 方法 3: 查看並停止
ps aux | grep metro
kill <PID>
```

---

## 🔧 常見指令

### 環境相關

```bash
# 重新載入環境變數
source ~/.zshrc

# 檢查環境變數
echo $ANDROID_HOME
echo $JAVA_HOME

# 檢查工具版本
java -version
node --version
adb version
```

### 設備相關

```bash
# 列出連接的設備
adb devices

# 重啟 adb
adb kill-server
adb start-server

# 安裝 APK 到設備
adb install -r android/app/build/outputs/apk/debug/app-debug.apk

# 查看設備日誌
adb logcat | grep "ReactNative"
```

### 專案相關

```bash
# 清理專案
cd android
./gradlew clean
cd ..

# 清理 Metro 快取
npm start -- --reset-cache

# 重新安裝依賴
rm -rf node_modules
npm install

# 完整清理
rm -rf node_modules
npm install
cd android && ./gradlew clean && cd ..
npm start -- --reset-cache
```

---

## ❓ 常見問題

### Q1: 執行腳本時提示「permission denied」

**解決方案：**

```bash
chmod +x scripts/*.sh
```

### Q2: 環境變數未載入（ANDROID_HOME 為空）

**解決方案：**

```bash
# 重新載入
source ~/.zshrc

# 或在當前 shell 手動設定
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Q3: adb devices 沒有顯示設備

**解決方案：**

1. 檢查 USB 連接（嘗試不同的 USB 埠或線材）
2. 確認設備已啟用 USB 偵錯
3. 在設備上允許 USB 偵錯授權
4. 重啟 adb：
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

### Q4: 編譯失敗

**解決方案：**

```bash
# 步驟 1: 清理專案
cd android
./gradlew clean
cd ..

# 步驟 2: 清理 Metro 快取
rm -rf $TMPDIR/metro-*
rm -rf $TMPDIR/haste-*

# 步驟 3: 重新啟動
npm start -- --reset-cache
```

### Q5: Metro 已經在運行，如何重新編譯？

**解決方案：**

使用快速執行腳本的選項 2：

```bash
./scripts/run-android.sh
# 選擇：2) 只編譯並運行 Android App
```

或直接執行：

```bash
npm run android
```

### Q6: 如何查看 Metro 日誌？

**解決方案：**

如果使用 `start-android-dev.sh`，Metro 日誌在：

```bash
tail -f /tmp/metro-bundler.log
```

如果手動啟動 Metro，它會直接顯示在終端。

### Q7: 首次編譯很慢

這是正常的！首次編譯需要：
- 下載 Gradle 依賴
- 下載 Android 庫
- 編譯所有代碼

可能需要 **5-15 分鐘**，請耐心等待。後續編譯會快很多。

---

## 📚 進階資源

### 詳細文檔

- [完整環境設置指南](./ANDROID_SETUP.md) - 包含詳細的安裝步驟
- [主 README](../README.md) - 專案總覽
- [React Native 官方文檔](https://reactnative.dev/docs/getting-started)

### 腳本原始碼

所有腳本都在 `scripts/` 目錄：

```
scripts/
├── check-android-env.sh      # 環境檢查
├── run-android.sh             # 快速執行
└── start-android-dev.sh       # 一鍵啟動
```

您可以查看和修改這些腳本以符合您的需求。

---

## 🎯 開發工作流程總結

### 每日開發流程

```bash
# 早上開始
1. 開啟終端
2. cd /Users/tony_1/Desktop/omni-project/omnichatV2-webview/WebChat-v2
3. ./scripts/start-android-dev.sh
4. 開始開發！

# 修改代碼
- 編輯 App.tsx 或其他檔案
- 儲存後自動重載

# 需要完全重載
- 搖動設備打開開發選單
- 點擊 "Reload"
- 或按 R 兩次

# 結束工作
- Ctrl+C 停止 Metro
- 或 kill <PID>
```

### 遇到問題時

```bash
# 步驟 1: 檢查環境
./scripts/check-android-env.sh

# 步驟 2: 檢查設備
adb devices

# 步驟 3: 清理重試
cd android && ./gradlew clean && cd ..
npm start -- --reset-cache

# 步驟 4: 重新啟動
./scripts/start-android-dev.sh
```

---

## 💡 最佳實踐

1. **使用一鍵啟動腳本** - `start-android-dev.sh` 是最快速且可靠的方式

2. **保持 Metro 運行** - 開發期間讓 Metro 持續運行，享受熱重載

3. **定期清理** - 如果遇到奇怪的問題，先清理專案再重試

4. **使用環境檢查** - 遇到問題時先運行 `check-android-env.sh`

5. **查看日誌** - 出錯時查看 Metro 和 Android 日誌以了解問題

---

## 🆘 需要幫助？

如果您遇到本指南未涵蓋的問題：

1. 查看 [完整環境設置指南](./ANDROID_SETUP.md) 的疑難排解章節
2. 檢查 [React Native 疑難排解](https://reactnative.dev/docs/troubleshooting)
3. 聯繫專案維護人員

---

**祝您開發順利！** 🎉

