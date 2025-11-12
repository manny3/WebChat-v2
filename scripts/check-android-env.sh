#!/bin/bash

# ============================================================================
# Android 環境快速檢查腳本
# ============================================================================
# 快速檢查 Android 開發環境是否已正確設置
# ============================================================================

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Android 環境檢查${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 檢查計數
ERRORS=0
WARNINGS=0

# 1. 檢查 JAVA_HOME
echo -n "檢查 JAVA_HOME... "
if [ -z "$JAVA_HOME" ]; then
    echo -e "${RED}✗ 未設定${NC}"
    echo -e "  ${YELLOW}請執行: source ~/.zshrc${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓${NC}"
    echo "  → $JAVA_HOME"
fi

# 2. 檢查 Java 版本
echo -n "檢查 Java 版本... "
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    echo -e "${GREEN}✓${NC} $JAVA_VERSION"
else
    echo -e "${RED}✗ Java 未安裝${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 3. 檢查 ANDROID_HOME
echo -n "檢查 ANDROID_HOME... "
if [ -z "$ANDROID_HOME" ]; then
    echo -e "${RED}✗ 未設定${NC}"
    echo -e "  ${YELLOW}請執行: source ~/.zshrc${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓${NC}"
    echo "  → $ANDROID_HOME"
    
    if [ ! -d "$ANDROID_HOME" ]; then
        echo -e "  ${RED}✗ 路徑不存在！${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi

# 4. 檢查 adb
echo -n "檢查 adb... "
if command -v adb &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    ADB_VERSION=$(adb version 2>&1 | head -n 1)
    echo "  → $ADB_VERSION"
else
    echo -e "${RED}✗ adb 不在 PATH 中${NC}"
    echo -e "  ${YELLOW}請執行: source ~/.zshrc${NC}"
    ERRORS=$((ERRORS + 1))
fi

# 5. 檢查連接的設備
if command -v adb &> /dev/null; then
    echo -n "檢查 Android 設備... "
    DEVICE_COUNT=$(adb devices | grep -v "List of devices" | grep -v "^$" | grep "device$" | wc -l | xargs)
    
    if [ "$DEVICE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} 發現 $DEVICE_COUNT 個設備"
        adb devices | grep "device$" | while read line; do
            echo "  → $line"
        done
    else
        echo -e "${YELLOW}⚠ 沒有連接的設備${NC}"
        echo "  請連接 Android 設備或啟動模擬器"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 6. 檢查 node_modules
echo -n "檢查專案依賴... "
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ node_modules 不存在${NC}"
    echo -e "  ${YELLOW}請執行: npm install${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# 總結
echo ""
echo -e "${BLUE}========================================${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ 環境檢查通過！可以開始開發${NC}"
    echo ""
    echo "執行以下指令啟動開發："
    echo -e "  ${BLUE}./scripts/start-android-dev.sh${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ 環境基本正常，但有 $WARNINGS 個警告${NC}"
    echo ""
    echo "您仍然可以嘗試運行："
    echo -e "  ${BLUE}./scripts/run-android.sh${NC}"
    exit 0
else
    echo -e "${RED}✗ 發現 $ERRORS 個錯誤，$WARNINGS 個警告${NC}"
    echo ""
    echo "請先修復錯誤："
    echo "  1. 如果環境變數未設定，請執行: source ~/.zshrc"
    echo "  2. 如果仍有問題，請檢查 ~/.zshrc 檔案"
    echo ""
    exit 1
fi

