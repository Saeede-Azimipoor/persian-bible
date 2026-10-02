import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'services/bookmarks_service.dart';
import 'services/favorites_service.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favorites = FavoritesService();
  final settings = SettingsService();
  final bookmarks = BookmarksService();
  await favorites.load();
  await settings.load();
  await bookmarks.load();
  runApp(PersianBibleApp(
    favorites: favorites,
    settings: settings,
    bookmarks: bookmarks,
  ));
}

class PersianBibleApp extends StatelessWidget {
  final FavoritesService favorites;
  final SettingsService settings;
  final BookmarksService bookmarks;

  const PersianBibleApp({
    super.key,
    required this.favorites,
    required this.settings,
    required this.bookmarks,
  });

  @override
  Widget build(BuildContext context) {
    // با عوض شدن تم، کل اپ بازسازی می‌شه
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Persian Bible',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MainShell(
            favorites: favorites,
            settings: settings,
            bookmarks: bookmarks,
          ),
        ),
      ),
    );
  }
}
