import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// تم اپ — پالت سرمه‌ای/نیلی
class AppTheme {
  static const _seed = Color(0xFF2B3A8F); // نیلی سرمه‌ای

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    return ThemeData(
      // کل پالت (دکمه‌ها، نشانگرها، هایلایت‌ها) از همین یه رنگ ساخته می‌شه
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
      useMaterial3: true,
      // فونت فارسی کل رابط کاربری
      textTheme: GoogleFonts.vazirmatnTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      // «شکل»: کارت‌های گردتر و باتم‌شیت با گوشه‌ی گرد
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
