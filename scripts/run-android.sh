#!/bin/bash

# ============================================================================
# Android App 快速執行腳本
# ============================================================================
# 提供彈性的執行選項：啟動 Metro、運行 Android、或兩者
# ============================================================================

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 取得腳本所在目錄的專案根目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Android App 快速執行${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 載入環境變數（如果未載入）
if [ -z "$ANDROID_HOME" ]; then
    echo -e "${YELLOW}⚠ 環境變數未載入，嘗試從 ~/.zshrc 載入...${NC}"
    if [ -f ~/.zshrc ]; then
        # 提取並執行 Android 相關的環境變數
        export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
        export ANDROID_HOME=$HOME/Library/Android/sdk
        export ANDROID_SDK_ROOT=$ANDROID_HOME
        export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/cmdline-tools/latest/bin
        echo -e "${GREEN}✓ 環境變數已載入${NC}"
    else
        echo -e "${RED}✗ 找不到 ~/.zshrc${NC}"
        exit 1
    fi
fi

# 切換到專案根目錄
cd "$PROJECT_ROOT"

# 顯示選單
echo "請選擇執行模式："
echo ""
echo -e "  ${CYAN}1)${NC} 只啟動 Metro Bundler"
echo -e "  ${CYAN}2)${NC} 只編譯並運行 Android App (需要 Metro 已運行)"
echo -e "  ${CYAN}3)${NC} 啟動 Metro 並運行 Android App (推薦)"
echo -e "  ${CYAN}4)${NC} 檢查環境並退出"
echo -e "  ${CYAN}q)${NC} 退出"
echo ""
read -p "請輸入選項 [1-4/q]: " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}>>> 啟動 Metro Bundler${NC}"
        echo ""
        npm start
        ;;
    
    2)
        echo ""
        echo -e "${BLUE}>>> 檢查環境...${NC}"
        
        # 檢查 adb
        if ! command -v adb &> /dev/null; then
            echo -e "${RED}✗ adb 未找到${NC}"
            echo "請確保 ANDROID_HOME 已正確設定"
            exit 1
        fi
        
        # 檢查設備
        DEVICE_COUNT=$(adb devices | grep -v "List of devices" | grep -v "^$" | grep "device$" | wc -l | xargs)
        if [ "$DEVICE_COUNT" -eq 0 ]; then
            echo -e "${YELLOW}⚠ 沒有連接的 Android 設備或模擬器${NC}"
            echo ""
            echo "請先："
            echo "  1. 連接 Android 設備並啟用 USB 偵錯"
            echo "  2. 或啟動 Android 模擬器"
            echo ""
            read -p "按 Enter 繼續嘗試運行，或 Ctrl+C 取消..."
        else
            echo -e "${GREEN}✓ 發現 $DEVICE_COUNT 個設備${NC}"
        fi
        
        echo ""
        echo -e "${BLUE}>>> 編譯並運行 Android App${NC}"
        echo -e "${YELLOW}注意：請確保 Metro Bundler 已在另一個終端運行${NC}"
        echo ""
        npm run android
        ;;
    
    3)
        echo ""
        echo -e "${BLUE}>>> 檢查環境...${NC}"
        
        # 檢查 adb
        if ! command -v adb &> /dev/null; then
            echo -e "${RED}✗ adb 未找到${NC}"
            echo "請確保 ANDROID_HOME 已正確設定"
            exit 1
        fi
        
        # 檢查設備
        DEVICE_COUNT=$(adb devices | grep -v "List of devices" | grep -v "^$" | grep "device$" | wc -l | xargs)
        if [ "$DEVICE_COUNT" -eq 0 ]; then
            echo -e "${YELLOW}⚠ 沒有連接的 Android 設備或模擬器${NC}"
            echo ""
            echo "請先："
            echo "  1. 連接 Android 設備並啟用 USB 偵錯"
            echo "  2. 或啟動 Android 模擬器"
            echo ""
            read -p "是否繼續？(y/N): " continue
            if [[ ! "$continue" =~ ^[Yy]$ ]]; then
                echo "已取消"
                exit 0
            fi
        else
            echo -e "${GREEN}✓ 發現 $DEVICE_COUNT 個設備${NC}"
        fi
        
        echo ""
        echo -e "${BLUE}>>> 啟動 Metro Bundler (背景執行)${NC}"
        npm start &
        METRO_PID=$!
        
        echo -e "${YELLOW}等待 Metro 啟動...${NC}"
        sleep 8
        
        echo ""
        echo -e "${BLUE}>>> 編譯並運行 Android App${NC}"
        echo ""
        
        if npm run android; then
            echo ""
            echo -e "${GREEN}========================================${NC}"
            echo -e "${GREEN}  ✓ Android App 已成功啟動！${NC}"
            echo -e "${GREEN}========================================${NC}"
            echo ""
            echo "Metro Bundler 正在背景執行 (PID: $METRO_PID)"
            echo ""
            echo "若要停止 Metro："
            echo -e "  ${CYAN}kill $METRO_PID${NC}"
            echo ""
            echo "或查看 Metro 日誌："
            echo -e "  ${CYAN}fg${NC}"
            echo ""
        else
            echo ""
            echo -e "${RED}✗ 編譯失敗${NC}"
            echo "停止 Metro Bundler..."
            kill $METRO_PID 2>/dev/null
            exit 1
        fi
        ;;
    
    4)
        echo ""
        "$SCRIPT_DIR/check-android-env.sh"
        ;;
    
    q|Q)
        echo "已退出"
        exit 0
        ;;
    
    *)
        echo -e "${RED}無效的選項${NC}"
        exit 1
        ;;
esac

