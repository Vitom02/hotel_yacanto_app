#!/bin/sh

# ============================================
# Xcode Cloud - Post Clone Script
# Hotel Yacanto - Flutter iOS Build
# ============================================

set -e

echo "=========================================="
echo "🚀 XCODE CLOUD - POST CLONE SCRIPT"
echo "=========================================="

# Ir al directorio raíz del proyecto Flutter
cd $CI_PRIMARY_REPOSITORY_PATH

echo ""
echo "📍 Directorio actual: $(pwd)"
echo ""

# ============================================
# INSTALAR FLUTTER
# ============================================
echo "📦 Instalando Flutter..."

# Clonar Flutter en el directorio home
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter

# Agregar Flutter al PATH
export PATH="$PATH:$HOME/flutter/bin"

echo "✅ Flutter instalado"
echo ""

# Verificar versión de Flutter
echo "📱 Versión de Flutter:"
flutter --version
echo ""

# ============================================
# CONFIGURAR FLUTTER
# ============================================
echo "⚙️  Configurando Flutter..."

# Desactivar analytics
flutter config --no-analytics

# Pre-download iOS artifacts
flutter precache --ios

echo "✅ Flutter configurado"
echo ""

# ============================================
# OBTENER DEPENDENCIAS
# ============================================
echo "📥 Obteniendo dependencias de Flutter..."
flutter pub get
echo "✅ Dependencias instaladas"
echo ""

# ============================================
# GENERAR CÓDIGO (si es necesario)
# ============================================
# Si usas build_runner, descomenta esto:
# echo "🔧 Generando código..."
# flutter pub run build_runner build --delete-conflicting-outputs
# echo "✅ Código generado"

# ============================================
# INSTALAR PODS
# ============================================
echo "🍫 Instalando CocoaPods..."
cd ios

# Limpiar pods anteriores
rm -rf Pods
rm -rf Podfile.lock

# Instalar pods
pod install --repo-update

echo "✅ CocoaPods instalados"
echo ""

cd ..

echo "=========================================="
echo "✅ POST CLONE COMPLETADO"
echo "=========================================="
