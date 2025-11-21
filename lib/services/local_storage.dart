import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String _boxName = 'userData';
  static const String _documentKey = 'document';
  static const String _fullNameKey = 'fullName';
  static Box? _box;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _isInitialized = true;
    }
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  static Future<void> _ensureBoxOpen() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _isInitialized = true;
    }
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  static Box get _getBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Box not initialized. Call LocalStorage.init() first.');
    }
    return _box!;
  }

  static Future<void> saveDocument(String document) async {
    await _ensureBoxOpen();
    await _box!.put(_documentKey, document);
    print('✅ LocalStorage: Documento guardado: $document');
    print('✅ LocalStorage: Verificación - Documento en Box: ${_box!.get(_documentKey)}');
  }

  static String? getDocument() {
    if (_box == null || !_box!.isOpen) {
      print('⚠️ LocalStorage: Box no está abierto al obtener documento');
      return null;
    }
    final document = _getBox.get(_documentKey) as String?;
    print('📖 LocalStorage: Documento obtenido: $document');
    return document;
  }

  static bool hasDocument() {
    if (_box == null || !_box!.isOpen) {
      print('⚠️ LocalStorage: Box no está abierto al verificar documento');
      return false;
    }
    final hasDoc = _getBox.containsKey(_documentKey) && _getBox.get(_documentKey) != null;
    print('🔍 LocalStorage: ¿Tiene documento?: $hasDoc (documento: ${_getBox.get(_documentKey)})');
    return hasDoc;
  }

  static Future<void> clearDocument() async {
    await _ensureBoxOpen();
    await _box!.delete(_documentKey);
    await _box!.delete(_fullNameKey);
  }

  static Future<void> saveFullName(String fullName) async {
    await _ensureBoxOpen();
    await _box!.put(_fullNameKey, fullName);
    print('✅ LocalStorage: Nombre completo guardado: $fullName');
    print('✅ LocalStorage: Verificación - Nombre en Box: ${_box!.get(_fullNameKey)}');
  }

  static String? getFullName() {
    if (_box == null || !_box!.isOpen) {
      return null;
    }
    return _getBox.get(_fullNameKey) as String?;
  }
}

