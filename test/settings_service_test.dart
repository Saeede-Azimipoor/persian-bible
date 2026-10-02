import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persian_bible/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('پیش‌فرض‌ها و ذخیره‌سازی تنظیمات', () async {
    SharedPreferences.setMockInitialValues({});

    final s = SettingsService();
    await s.load();
    expect(s.themeMode, ThemeMode.system);
    expect(s.fontSize, 22);
    expect(s.faFont, 'naskh');

    await s.setFontSize(26);
    await s.setThemeMode(ThemeMode.dark);
    await s.setFaFont('nastaliq');

    final s2 = SettingsService();
    await s2.load();
    expect(s2.fontSize, 26);
    expect(s2.themeMode, ThemeMode.dark);
    expect(s2.faFont, 'nastaliq');
  });
}
