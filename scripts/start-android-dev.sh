#!/bin/bash

# ============================================================================
# Android 開發環境一鍵啟動腳本
# ============================================================================
# 自動完成所有步驟：環境檢查 → 啟動 Metro → 編譯安裝 App
# ============================================================================

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 取得腳本所在目錄的專案根目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 顯示標題
clear
echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                                        ║${NC}"
echo -e "${MAGENTA}║    Android 開發環境一鍵啟動           ║${NC}"
echo -e "${MAGENTA}║                                        ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
echo ""

# 載入環境變數（如果未載入）
if [ -z "$ANDROID_HOME" ]; then
    echo -e "${YELLOW}[1/6] 載入環境變數...${NC}"
    if [ -f ~/.zshrc ]; then
        export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
        export ANDROID_HOME=$HOME/Library/Android/sdk
        export ANDROID_SDK_ROOT=$ANDROID_HOME
        export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/cmdline-tools/latest/bin
        echo -e "${GREEN}      ✓ 環境變數已載入${NC}"
    else
        echo -e "${RED}      ✗ 找不到 ~/.zshrc${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}[1/6] ✓ 環境變數已就緒${NC}"
fi
echo ""

# 切換到專案根目錄
cd "$PROJECT_ROOT"

# 檢查環境
echo -e "${YELLOW}[2/6] 檢查開發環境...${NC}"

# 檢查 Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}      ✗ Java 未安裝${NC}"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
echo -e "${GREEN}      ✓ Java $JAVA_VERSION${NC}"

# 檢查 adb
if ! command -v adb &> /dev/null; then
    echo -e "${RED}      ✗ adb 未找到${NC}"
    echo -e "${YELLOW}      提示: 請執行 source ~/.zshrc 然後重試${NC}"
    exit 1
fi
echo -e "${GREEN}      ✓ adb 可用${NC}"

# 檢查 node_modules
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}      ⚠ node_modules 不存在${NC}"
    echo -e "${CYAN}      正在安裝依賴...${NC}"
    npm install
    if [ $? -ne 0 ]; then
        echo -e "${RED}      ✗ 依賴安裝失敗${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}      ✓ 專案依賴已就緒${NC}"
echo ""

# 檢查設備
echo -e "${YELLOW}[3/6] 檢查 Android 設備...${NC}"
DEVICE_COUNT=$(adb devices | grep -v "List of devices" | grep -v "^$" | grep "device$" | wc -l | xargs)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${RED}      ✗ 沒有連接的 Android 設備或模擬器${NC}"
    echo ""
    echo "請選擇："
    echo -e "  ${CYAN}1)${NC} 我已連接設備，重新檢查"
    echo -e "  ${CYAN}2)${NC} 列出可用的模擬器"
    echo -e "  ${CYAN}3)${NC} 繼續嘗試（不推薦）"
    echo -e "  ${CYAN}q)${NC} 退出"
    echo ""
    read -p "請選擇 [1-3/q]: " device_choice
    
    case $device_choice in
        1)
            DEVICE_COUNT=$(adb devices | grep -v "List of devices" | grep -v "^$" | grep "device$" | wc -l | xargs)
            if [ "$DEVICE_COUNT" -eq 0 ]; then
                echo -e "${RED}      仍然沒有發現設備${NC}"
                exit 1
            fi
            echo -e "${GREEN}      ✓ 發現 $DEVICE_COUNT 個設備${NC}"
            ;;
        2)
            echo ""
            echo -e "${CYAN}可用的模擬器：${NC}"
            if command -v emulator &> /dev/null; then
                emulator -list-avds
                echo ""
                echo "啟動模擬器："
                echo -e "  ${CYAN}emulator -avd <模擬器名稱>${NC}"
                echo ""
            else
                echo -e "${RED}emulator 指令未找到${NC}"
            fi
            exit 0
            ;;
        3)
            echo -e "${YELLOW}      ⚠ 警告：沒有設備，編譯可能失敗${NC}"
            ;;
        *)
            echo "已退出"
            exit 0
            ;;
    esac
else
    echo -e "${GREEN}      ✓ 發現 $DEVICE_COUNT 個設備${NC}"
    adb devices | grep "device$" | while read device status; do
        echo -e "${CYAN}        → $device${NC}"
    done
fi
echo ""

# 啟動 Metro
echo -e "${YELLOW}[4/6] 啟動 Metro Bundler...${NC}"
npm start > /tmp/metro-bundler.log 2>&1 &
METRO_PID=$!
echo -e "${GREEN}      ✓ Metro 已在背景啟動 (PID: $METRO_PID)${NC}"
echo ""

# 等待 Metro 就緒
echo -e "${YELLOW}[5/6] 等待 Metro 就緒...${NC}"
echo -n "      "
for i in {1..10}; do
    echo -n "."
    sleep 1
done
echo ""
echo -e "${GREEN}      ✓ Metro 應該已經就緒${NC}"
echo ""

# 編譯並安裝 App
echo -e "${YELLOW}[6/6] 編譯並安裝 Android App...${NC}"
echo -e "${CYAN}      這可能需要幾分鐘，請耐心等待...${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if npm run android; then
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                        ║${NC}"
    echo -e "${GREEN}║       ✓ Android App 啟動成功！        ║${NC}"
    echo -e "${GREEN}║                                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Metro Bundler 正在背景執行${NC}"
    echo -e "  PID: ${YELLOW}$METRO_PID${NC}"
    echo -e "  日誌: ${YELLOW}/tmp/metro-bundler.log${NC}"
    echo ""
    echo -e "${CYAN}查看 Metro 日誌：${NC}"
    echo -e "  ${YELLOW}tail -f /tmp/metro-bundler.log${NC}"
    echo ""
    echo -e "${CYAN}停止 Metro：${NC}"
    echo -e "  ${YELLOW}kill $METRO_PID${NC}"
    echo ""
    echo -e "${CYAN}重新載入 App：${NC}"
    echo -e "  ${YELLOW}在設備上按 R 兩次${NC}"
    echo -e "  ${YELLOW}或搖動設備開啟開發選單${NC}"
    echo ""
    
    # 詢問是否要查看 Metro 日誌
    read -p "是否要查看 Metro 即時日誌？(y/N): " show_logs
    if [[ "$show_logs" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${CYAN}顯示 Metro 日誌 (Ctrl+C 退出)：${NC}"
        echo ""
        tail -f /tmp/metro-bundler.log
    fi
    
else
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                        ║${NC}"
    echo -e "${RED}║         ✗ 編譯失敗                    ║${NC}"
    echo -e "${RED}║                                        ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}正在停止 Metro Bundler...${NC}"
    kill $METRO_PID 2>/dev/null
    echo ""
    echo -e "${CYAN}常見問題排除：${NC}"
    echo ""
    echo -e "${YELLOW}1. 清理專案重試：${NC}"
    echo -e "   cd android && ./gradlew clean && cd .."
    echo -e "   npm start -- --reset-cache"
    echo ""
    echo -e "${YELLOW}2. 檢查設備連接：${NC}"
    echo -e "   adb devices"
    echo ""
    echo -e "${YELLOW}3. 重啟 adb：${NC}"
    echo -e "   adb kill-server && adb start-server"
    echo ""
    exit 1
fi

