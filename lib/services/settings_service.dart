import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تنظیمات ظاهری اپ: تم، فونت، اندازه‌ی متن — همه دائمی ذخیره می‌شن
class SettingsService extends ChangeNotifier {
  static const _kTheme = 'theme_mode'; // 'system' | 'light' | 'dark'
  static const _kFaFont = 'fa_font';
  static const _kEnFont = 'en_font';
  static const _kFontSize = 'font_size';

  ThemeMode _themeMode = ThemeMode.system;
  String _faFont = 'naskh';
  String _enFont = 'notoSerif';
  double _fontSize = 22;

  ThemeMode get themeMode => _themeMode;
  String get faFont => _faFont;
  String get enFont => _enFont;
  double get fontSize => _fontSize;

  static const Map<String, String> faFontNames = {
    'nastaliq': 'نستعلیق',
    'naskh': 'نسخ',
    'vazirmatn': 'وزیرمتن',
  };

  static const Map<String, String> enFontNames = {
    'notoSerif': 'Noto Serif',
    'lora': 'Lora',
    'merriweather': 'Merriweather',
  };

  // ارتفاع خط پیشنهادی هر فونت فارسی (نستعلیق قدبلنده!)
  static const Map<String, double> _faLineHeights = {
    'nastaliq': 2.6,
    'naskh': 2.2,
    'vazirmatn': 2.0,
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = switch (prefs.getString(_kTheme)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _faFont = prefs.getString(_kFaFont) ?? 'naskh';
    _enFont = prefs.getString(_kEnFont) ?? 'notoSerif';
    _fontSize = prefs.getDouble(_kFontSize) ?? 22;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kTheme,
        switch (_themeMode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        });
    await prefs.setString(_kFaFont, _faFont);
    await prefs.setString(_kEnFont, _enFont);
    await prefs.setDouble(_kFontSize, _fontSize);
  }

 Future<void> setThemeMode(ThemeMode mode) async {
  _themeMode = mode;
  notifyListeners();
  await _save();
}

Future<void> setFaFont(String id) async {
  _faFont = id;
  notifyListeners();
  await _save();
}

Future<void> setEnFont(String id) async {
  _enFont = id;
  notifyListeners();
  await _save();
}

Future<void> setFontSize(double size) async {
  _fontSize = size;
  notifyListeners();
  await _save();
}


  /// استایل یه فونت مشخص — برای پیش‌نمایش گزینه‌ها
  /// فونت‌ها داخل خود اپ باندل شدن (assets/fonts) و بدون اینترنت کار می‌کنن
  static TextStyle previewStyle({
    required bool rtl,
    required String fontId,
    double fontSize = 20,
  }) {
    final String family;
    if (rtl) {
      family = switch (fontId) {
        'nastaliq' => 'NotoNastaliqUrdu',
        'vazirmatn' => 'Vazirmatn',
        _ => 'NotoNaskhArabic',
      };
    } else {
      family = switch (fontId) {
        'lora' => 'Lora',
        'merriweather' => 'Merriweather',
        _ => 'NotoSerif',
      };
    }
    return TextStyle(fontFamily: family, fontSize: fontSize);
  }

  /// استایل متن کتاب مقدس با فونت و سایز انتخاب‌شده‌ی کاربر
  TextStyle verseStyle({
    required bool rtl,
    double? fontSize,
    double? height,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return previewStyle(
      rtl: rtl,
      fontId: rtl ? _faFont : _enFont,
      fontSize: fontSize ?? _fontSize,
    ).copyWith(
      height: height ?? (rtl ? _faLineHeights[_faFont]! : 2.0),
      color: color,
      fontWeight: fontWeight,
    );
  }
}
