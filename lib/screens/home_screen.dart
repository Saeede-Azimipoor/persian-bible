import 'package:flutter/material.dart';

import '../data/bible_meta.dart';
import '../data/translations.dart';
import '../services/bible_service.dart';
import '../services/bookmarks_service.dart';
import '../services/favorites_service.dart';
import '../services/settings_service.dart';
import '../utils/format.dart';

const List<(int, int, int)> _dailyVerses = [
  (24, 33, 3),
  (19, 23, 1),
  (43, 3, 16),
  (50, 4, 13),
  (19, 119, 105),
  (20, 3, 5),
  (23, 41, 10),
  (45, 8, 28),
  (40, 11, 28),
  (19, 46, 1),
];

class HomeScreen extends StatelessWidget {
  final BibleService service;
  final BibleTranslationInfo translation;
  final SettingsService settings;
  final BookmarksService bookmarks;
  final int lastReadPage;
  final VoidCallback onContinueReading;
  final ValueChanged<FavoriteRef> onOpenVerse;
  final ValueChanged<BookmarkRef> onOpenBookmark;

  const HomeScreen({
    super.key,
    required this.service,
    required this.translation,
    required this.settings,
    required this.bookmarks,
    required this.lastReadPage,
    required this.onContinueReading,
    required this.onOpenVerse,
    required this.onOpenBookmark,
  });

  FavoriteRef get _todayVerse {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final (b, c, v) = _dailyVerses[dayOfYear % _dailyVerses.length];
    return FavoriteRef(bookNumber: b, chapter: c, verse: v);
  }

  @override
  Widget build(BuildContext context) {
    final rtl = translation.rtl;
    final names = bookNamesFor(translation);
    final bc = pageToBookChapter(lastReadPage);
    final lastLabel =
        '${names[bc.bookIndex]} ${trNum(bc.chapter, rtl: rtl)}';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
            Text('سلام 👋',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('امروز چی می‌خونی؟',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            _sectionTitle('آیه‌ی روز'),
            _verseOfDayCard(context),
            const SizedBox(height: 24),
            _sectionTitle('مطالعه'),
            Card(
              child: ListTile(
                title: const Text('ادامه‌ی مطالعه'),
                subtitle: Text(lastLabel),
                trailing: FilledButton(
                  onPressed: onContinueReading,
                  child: const Text('ادامه بده'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('نشانه‌ها'),
            ListenableBuilder(
              listenable: bookmarks,
              builder: (context, _) {
                final items = bookmarks.all;
                if (items.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'هنوز نشانه‌ای ثبت نکردی — توی صفحه‌ی کتاب مقدس روی آیکون 🔖 بزن',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _bookmarkTile(context, items[i]),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _bookmarkTile(BuildContext context, BookmarkRef b) {
    final rtl = translation.rtl;
    final label =
        '${bookNamesFor(translation)[b.bookNumber - 1]} ${trNum(b.chapter, rtl: rtl)}';
    return ListTile(
      leading: Icon(Icons.bookmark,
          color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'حذف نشانه',
        onPressed: () => bookmarks.toggle(b),
      ),
      onTap: () => onOpenBookmark(b),
    );
  }

  Widget _verseOfDayCard(BuildContext context) {
    final rtl = translation.rtl;
    final ref = _todayVerse;
    final label =
        '${bookNamesFor(translation)[ref.bookNumber - 1]} ${trNum(ref.chapter, rtl: rtl)}:${trNum(ref.verse, rtl: rtl)}';
    return Card(
      child: InkWell(
        onTap: () => onOpenVerse(ref),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: service.loadBook(ref.bookNumber),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                    height: 80,
                    child:
                        Center(child: CircularProgressIndicator()));
              }
              final verse = snapshot.data!
                  .chapters[ref.chapter - 1].verses
                  .firstWhere((v) => v.number == ref.verse);
              return Directionality(
                textDirection: dirOf(rtl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('«${verse.text}»',
                        style: settings.verseStyle(
                            rtl: rtl, fontSize: 20)),
                    const SizedBox(height: 12),
                    Text(label,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
