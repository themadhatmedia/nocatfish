import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storage = StorageService();
  final Rx<ThemeMode> _themeMode = ThemeMode.dark.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
  }

  void loadThemeMode() {
    final savedMode = _storage.getThemeMode();
    if (savedMode != null) {
      _themeMode.value = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    _themeMode.value = _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storage.saveThemeMode(_themeMode.value == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode.value = mode;
    await _storage.saveThemeMode(mode == ThemeMode.light ? 'light' : 'dark');
  }
}
