#!/bin/sh

# ============================================
# Xcode Cloud - Post Xcodebuild Script
# Hotel Yacanto - Flutter iOS Build
# ============================================

set -e

echo "=========================================="
echo "📦 XCODE CLOUD - POST XCODEBUILD SCRIPT"
echo "=========================================="

echo ""
echo "📍 Directorio de artefactos: $CI_ARCHIVE_PATH"
echo "📍 Build number: $CI_BUILD_NUMBER"
echo "📍 Commit: $CI_COMMIT"
echo ""

# ============================================
# INFORMACIÓN DEL BUILD
# ============================================
echo "📱 Información del build:"
echo "   - Bundle ID: com.vistasouth.hotelyacanto"
echo "   - Build Number: $CI_BUILD_NUMBER"
echo "   - Branch: $CI_BRANCH"
echo "   - Commit: $CI_COMMIT"
echo ""

# ============================================
# VERIFICAR ARCHIVE
# ============================================
if [ -d "$CI_ARCHIVE_PATH" ]; then
    echo "✅ Archive generado correctamente"
    echo "   Path: $CI_ARCHIVE_PATH"
else
    echo "⚠️  Archive path no encontrado (normal si no hay archive)"
fi

echo ""
echo "=========================================="
echo "✅ POST XCODEBUILD COMPLETADO"
echo "=========================================="
echo ""
echo "📲 El build será enviado a App Store Connect / TestFlight"
echo "   automáticamente por Xcode Cloud."
echo ""
