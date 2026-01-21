#!/bin/sh

# ============================================
# Xcode Cloud - Pre Xcodebuild Script
# Hotel Yacanto - Flutter iOS Build
# ============================================

set -e

echo "=========================================="
echo "🏗️  XCODE CLOUD - PRE XCODEBUILD SCRIPT"
echo "=========================================="

# Ir al directorio raíz del proyecto Flutter
cd $CI_PRIMARY_REPOSITORY_PATH

echo ""
echo "📍 Directorio actual: $(pwd)"
echo ""

# ============================================
# CONFIGURAR PATH DE FLUTTER
# ============================================
export PATH="$PATH:$HOME/flutter/bin"

echo "📱 Verificando Flutter..."
flutter --version
echo ""

# ============================================
# BUILD FLUTTER PARA iOS
# ============================================
echo "🔨 Compilando Flutter para iOS..."

# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Compilar para iOS (release)
flutter build ios --release --no-codesign

echo ""
echo "✅ Flutter build completado"
echo ""

# ============================================
# VERIFICAR ARCHIVOS GENERADOS
# ============================================
echo "📁 Verificando archivos generados..."

if [ -d "build/ios/iphoneos/Runner.app" ]; then
    echo "✅ Runner.app generado correctamente"
else
    echo "❌ ERROR: Runner.app no encontrado"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ PRE XCODEBUILD COMPLETADO"
echo "=========================================="
