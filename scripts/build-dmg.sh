#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="ClipHist"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-Installer"
DMG_PATH="$BUILD_DIR/$DMG_NAME.dmg"
DMG_STAGING="$BUILD_DIR/dmg-staging"
VERSION="1.0.0"

SDK_PATH=$(xcrun --show-sdk-path)
TARGET="arm64-apple-macosx14.0"

SWIFT_FILES=(
    "$PROJECT_DIR/ClipHist/Sources/Models/ClipboardItem.swift"
    "$PROJECT_DIR/ClipHist/Sources/Models/ClipboardStore.swift"
    "$PROJECT_DIR/ClipHist/Sources/Services/Accessibility.swift"
    "$PROJECT_DIR/ClipHist/Sources/Services/ClipboardMonitor.swift"
    "$PROJECT_DIR/ClipHist/Sources/Services/HotKeyManager.swift"
    "$PROJECT_DIR/ClipHist/Sources/Services/PasteService.swift"
    "$PROJECT_DIR/ClipHist/Sources/Views/ClipboardRowView.swift"
    "$PROJECT_DIR/ClipHist/Sources/Views/ClipboardListView.swift"
    "$PROJECT_DIR/ClipHist/Sources/Views/ClipboardHistoryPanel.swift"
    "$PROJECT_DIR/ClipHist/Sources/Views/MenuBarView.swift"
    "$PROJECT_DIR/ClipHist/Sources/Views/SettingsView.swift"
    "$PROJECT_DIR/ClipHist/Sources/ClipHistApp.swift"
)

echo "=== ClipHist Build & DMG ==="
echo "Version: $VERSION"
echo ""

# --- Clean ---
echo "[1/5] Limpando build anterior..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# --- Compile ---
echo "[2/5] Compilando Swift..."
swiftc \
    -target "$TARGET" \
    -sdk "$SDK_PATH" \
    -O \
    -whole-module-optimization \
    -module-name "$APP_NAME" \
    -emit-executable \
    -o "$BUILD_DIR/$APP_NAME" \
    "${SWIFT_FILES[@]}"

echo "    Binario compilado com sucesso!"

# --- Create .app bundle ---
echo "[3/5] Criando bundle $APP_NAME.app..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

mv "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cp "$PROJECT_DIR/ClipHist/Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

if [ -d "$PROJECT_DIR/ClipHist/Resources/Assets.xcassets" ]; then
    if command -v actool &>/dev/null; then
        actool \
            --compile "$APP_BUNDLE/Contents/Resources" \
            --platform macosx \
            --minimum-deployment-target 13.0 \
            "$PROJECT_DIR/ClipHist/Resources/Assets.xcassets" 2>/dev/null || true
    fi
fi

cat > "$APP_BUNDLE/Contents/PkgInfo" <<< "APPL????"

echo "    Bundle criado!"

# --- Sign ad-hoc & remove quarantine ---
echo "[4/5] Assinando ad-hoc e removendo quarentena..."
xattr -cr "$APP_BUNDLE" 2>/dev/null || true
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || echo "    (codesign nao disponivel, pulando)"
xattr -dr com.apple.quarantine "$APP_BUNDLE" 2>/dev/null || true

# --- Create DMG ---
echo "[5/5] Gerando DMG instalador..."
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"

cp -R "$APP_BUNDLE" "$DMG_STAGING/"

ln -s /Applications "$DMG_STAGING/Applications"

cat > "$DMG_STAGING/.background_README.txt" << 'BGEOF'
Arraste ClipHist para a pasta Applications para instalar.
BGEOF

rm -f "$DMG_PATH"

hdiutil create \
    -volname "$APP_NAME $VERSION" \
    -srcfolder "$DMG_STAGING" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    "$DMG_PATH"

rm -rf "$DMG_STAGING"

echo ""
echo "=== Build concluido! ==="
echo ""
echo "  App:  $APP_BUNDLE"
echo "  DMG:  $DMG_PATH"
echo "  Size: $(du -h "$DMG_PATH" | cut -f1)"
echo ""
echo "Para instalar:"
echo "  1. Abra $DMG_PATH"
echo "  2. Arraste ClipHist.app para Applications"
echo "  3. Abra ClipHist e conceda permissao de Acessibilidade"
echo ""
