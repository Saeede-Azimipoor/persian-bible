import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bible_meta.dart';
import '../data/translations.dart';
import '../services/bible_service.dart';
import '../services/bookmarks_service.dart';
import '../services/favorites_service.dart';
import '../services/settings_service.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reader_screen.dart';

class MainShell extends StatefulWidget {
  final FavoritesService favorites;
  final SettingsService settings;
  final BookmarksService bookmarks;

  const MainShell({
    super.key,
    required this.favorites,
    required this.settings,
    required this.bookmarks,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 1;
  late BibleTranslationInfo _translation;
  late BibleService _service;
  final Map<String, BibleService> _services = {};
  int? _lastReadPage;
  // هر پرش برنامه‌ریزی‌شده این شمارنده رو زیاد می‌کنه تا ریدر با
  // کلید جدید از نو ساخته بشه و PageController صفحه‌ی درست رو بگیره
  int _jumpNonce = 0;

  static const _kLastPage = 'last_read_page';
  static const _kTranslation = 'translation_id';

  BibleService _serviceFor(BibleTranslationInfo t) =>
      _services.putIfAbsent(t.id, () => BibleService(assetDir: t.assetDir));

  @override
  void initState() {
    super.initState();
    _translation = availableTranslations.first;
    _service = _serviceFor(_translation);
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_kLastPage);
    final tid = prefs.getString(_kTranslation);
    if (!mounted) return;
    setState(() {
      if (tid != null) {
        _translation = translationById(tid);
        _service = _serviceFor(_translation);
      }
      if (page != null && page >= 0 && page < totalChapters) {
        _lastReadPage = page;
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastReadPage != null) {
      await prefs.setInt(_kLastPage, _lastReadPage!);
    }
    await prefs.setString(_kTranslation, _translation.id);
  }

  void _onReaderPage(int page) {
    _lastReadPage = page;
    _saveState();
  }

  void _onTranslationChanged(BibleTranslationInfo t) {
    setState(() {
      _translation = t;
      _service = _serviceFor(t);
    });
    _saveState();
  }

  void _jumpToPage(int page) {
    _lastReadPage = page;
    _jumpNonce++;
    _saveState();
    setState(() => _tab = 1);
  }

  void _jumpToRef(FavoriteRef ref) {
    _jumpToPage(bookChapterToPage(ref.bookNumber - 1, ref.chapter));
  }

  void _jumpToBookmark(BookmarkRef ref) {
    _jumpToPage(bookChapterToPage(ref.bookNumber - 1, ref.chapter));
  }

  @override
  Widget build(BuildContext context) {
    // هر تغییر تنظیمات (تم، فونت، سایز) کل شل رو زنده بازسازی می‌کنه
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final settings = widget.settings;
        return Scaffold(
          body: IndexedStack(
            index: _tab,
            children: [
              HomeScreen(
                service: _service,
                translation: _translation,
                settings: settings,
                bookmarks: widget.bookmarks,
                lastReadPage: _lastReadPage ?? 0,
                onContinueReading: () => setState(() => _tab = 1),
                onOpenVerse: _jumpToRef,
                onOpenBookmark: _jumpToBookmark,
              ),
              ReaderScreen(
                key: ValueKey('${_translation.id}-$_jumpNonce'),
                translation: _translation,
                service: _service,
                favorites: widget.favorites,
                settings: settings,
                bookmarks: widget.bookmarks,
                initialPage: _lastReadPage ?? 0,
                onPageChanged: _onReaderPage,
                onTranslationChanged: _onTranslationChanged,
              ),
              FavoritesScreen(
                favorites: widget.favorites,
                settings: widget.settings,
                onSelect: _jumpToRef,
              ),

              ProfileScreen(settings: settings),
            ],
          ),
          bottomNavigationBar: _FloatingTabBar(
            current: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
        );
      },
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _FloatingTabBar({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(28),
          color: scheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(context, 0, Icons.home_outlined, Icons.home, 'خانه'),
                _item(context, 1, Icons.menu_book_outlined, Icons.menu_book,
                    'کتاب مقدس'),
                _item(context, 2, Icons.star_outline, Icons.star,
                    'علاقه‌مندی‌ها'),
                _item(context, 3, Icons.person_outline, Icons.person,
                    'پروفایل'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData outlined,
      IconData filled, String label) {
    final scheme = Theme.of(context).colorScheme;
    final selected = current == index;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? filled : outlined, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
