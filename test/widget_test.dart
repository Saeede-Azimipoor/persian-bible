import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persian_bible/screens/main_shell.dart';
import 'package:persian_bible/services/favorites_service.dart';
import 'package:persian_bible/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persian_bible/services/bookmarks_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Widget> buildApp() async {
    SharedPreferences.setMockInitialValues({});
    final favorites = FavoritesService();
    final settings = SettingsService();
    await favorites.load();
    await settings.load();
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MainShell(
  favorites: favorites,
  settings: settings,
  bookmarks: BookmarksService(),
),

      ),
    );
  }

  testWidgets('باز کردن تب کتاب مقدس', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('کتاب مقدس'));
    await tester.pump(const Duration(seconds: 1));

    // قرص بالای صفحه اسم کتاب رو نشون می‌ده
    expect(find.textContaining('پیدایش'), findsWidgets);
  });

  testWidgets('تب پروفایل تنظیمات را نشان می‌دهد', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('پروفایل'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('فونت فارسی'), findsOneWidget);
    expect(find.text('نستعلیق'), findsOneWidget);
    expect(find.text('اندازه‌ی متن', skipOffstage: false),
        findsOneWidget);
  });
}
