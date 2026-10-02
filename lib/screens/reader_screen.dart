import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/bible_meta.dart';
import '../data/translations.dart';
import '../models/bible.dart';
import '../services/bible_service.dart';
import '../services/bookmarks_service.dart';
import '../services/favorites_service.dart';
import '../services/settings_service.dart';
import '../utils/format.dart';
import 'search_screen.dart';

class ReaderScreen extends StatefulWidget {
  final BibleTranslationInfo translation;
  final BibleService service;
  final FavoritesService favorites;
  final SettingsService settings;
  final BookmarksService bookmarks;
  final int initialPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<BibleTranslationInfo> onTranslationChanged;

  const ReaderScreen({
    super.key,
    required this.translation,
    required this.service,
    required this.favorites,
    required this.settings,
    required this.bookmarks,
    required this.initialPage,
    required this.onPageChanged,
    required this.onTranslationChanged,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openBookPicker() async {
    final picked = await showModalBottomSheet<({int bookIndex, int chapter})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BookChapterPicker(
        bookNames: bookNamesFor(widget.translation),
        rtl: widget.translation.rtl,
      ),
    );
    if (picked != null) {
      _goToPage(bookChapterToPage(picked.bookIndex, picked.chapter));
    }
  }

  Future<void> _openTranslationPicker() async {
    final picked = await showModalBottomSheet<BibleTranslationInfo>(
      context: context,
      builder: (_) => _TranslationPicker(current: widget.translation),
    );
    if (picked != null && picked.id != widget.translation.id) {
      widget.onTranslationChanged(picked);
    }
  }

  Future<void> _openSearch() async {
    final ref = await Navigator.push<FavoriteRef>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          service: widget.service,
          translation: widget.translation,
          settings: widget.settings,
        ),
      ),
    );
    if (ref != null) {
      _goToPage(bookChapterToPage(ref.bookNumber - 1, ref.chapter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translation;
    final bc = pageToBookChapter(_currentPage);
    final names = bookNamesFor(t);

    return Scaffold(
      appBar: AppBar(
        title: _TopPill(
          bookLabel: '${names[bc.bookIndex]} ${trNum(bc.chapter, rtl: t.rtl)}',
          translationLabel: t.shortName,
          onBookTap: _openBookPicker,
          onTranslationTap: _openTranslationPicker,
        ),
        actions: [
          ListenableBuilder(
            listenable: widget.bookmarks,
            builder: (context, _) {
              final bc = pageToBookChapter(_currentPage);
              final ref = BookmarkRef(
                  bookNumber: bc.bookIndex + 1, chapter: bc.chapter);
              final marked = widget.bookmarks.isBookmarked(ref);
              return IconButton(
                icon: Icon(
                    marked ? Icons.bookmark : Icons.bookmark_border),
                tooltip: 'نشانه',
                onPressed: () async {
                  await widget.bookmarks.toggle(ref);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            marked ? 'نشانه پاک شد' : 'نشانه شد 🔖'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
        ],
      ),
      // فقط سوایپ — دکمه‌ی شناور حذف شد
      body: Directionality(
        textDirection: dirOf(t.rtl),
        child: PageView.builder(
          controller: _pageController,
          itemCount: totalChapters,
          onPageChanged: (page) {
            setState(() => _currentPage = page);
            widget.onPageChanged(page);
          },
          itemBuilder: (context, page) {
            final b = pageToBookChapter(page);
            return _ChapterPage(
              bookIndex: b.bookIndex,
              chapter: b.chapter,
              service: widget.service,
              favorites: widget.favorites,
              settings: widget.settings,
              translation: t,
            );
          },
        ),
      ),
    );
  }
}

class _ChapterPage extends StatelessWidget {
  final int bookIndex;
  final int chapter;
  final BibleService service;
  final FavoritesService favorites;
  final SettingsService settings;
  final BibleTranslationInfo translation;

  const _ChapterPage({
    required this.bookIndex,
    required this.chapter,
    required this.service,
    required this.favorites,
    required this.settings,
    required this.translation,
  });

  /// منوی لانگ‌پرس: علاقه‌مندی / کپی / اشتراک‌گذاری
  Future<void> _showVerseMenu(BuildContext context, Verse verse) async {
    final ref = FavoriteRef(
      bookNumber: bookIndex + 1,
      chapter: chapter,
      verse: verse.number,
    );
    final isFav = favorites.isFavorite(ref);
    final rtl = translation.rtl;
    final label =
        '${bookNamesFor(translation)[bookIndex]} ${trNum(chapter, rtl: rtl)}:${trNum(verse.number, rtl: rtl)}';
    final fullText = '«${verse.text}»\n— $label';

    await showModalBottomSheet(
      context: context,
      builder: (_) => Directionality(
        textDirection: dirOf(rtl),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(label,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: Icon(
                    isFav ? Icons.star : Icons.star_outline,
                    color: Colors.amber),
                title: Text(isFav
                    ? 'حذف از علاقه‌مندی‌ها'
                    : 'افزودن به علاقه‌مندی‌ها'),
                onTap: () async {
                  await favorites.toggle(ref);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('کپی آیه'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: fullText));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('کپی شد 📋'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('اشتراک‌گذاری'),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(fullText);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rtl = translation.rtl;
    return FutureBuilder(
      future: service.loadBook(bookIndex + 1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطا: ${snapshot.error}'));
        }
        final ch = snapshot.data!.chapters[chapter - 1];
        final hasHeading = ch.heading != null && ch.heading!.isNotEmpty;
        return Directionality(
          textDirection: dirOf(rtl),
          child: ListenableBuilder(
            listenable: favorites,
            builder: (context, _) => ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
              itemCount: ch.verses.length + (hasHeading ? 1 : 0),
              itemBuilder: (context, i) {
                if (hasHeading && i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      ch.heading!,
                      textAlign: TextAlign.center,
                      style: settings.verseStyle(
                          rtl: rtl,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                final verse = ch.verses[i - (hasHeading ? 1 : 0)];
                return _verseTile(context, verse, rtl);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _verseTile(BuildContext context, Verse verse, bool rtl) {
    final ref = FavoriteRef(
      bookNumber: bookIndex + 1,
      chapter: chapter,
      verse: verse.number,
    );
    final isFav = favorites.isFavorite(ref);
    return GestureDetector(
      onLongPress: () => _showVerseMenu(context, verse),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: isFav
            ? BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Text(
                    ' ${trNum(verse.number, rtl: rtl)} ',
                    style: settings.verseStyle(
                      rtl: rtl,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              TextSpan(text: verse.text),
            ],
          ),
          style: settings.verseStyle(rtl: rtl),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}

class _TopPill extends StatelessWidget {
  final String bookLabel;
  final String translationLabel;
  final VoidCallback onBookTap;
  final VoidCallback onTranslationTap;

  const _TopPill({
    required this.bookLabel,
    required this.translationLabel,
    required this.onBookTap,
    required this.onTranslationTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(bookLabel, onBookTap),
          Container(width: 1, height: 24, color: scheme.outlineVariant),
          _segment(translationLabel, onTranslationTap),
        ],
      ),
    );
  }

  Widget _segment(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _BookChapterPicker extends StatefulWidget {
  final List<String> bookNames;
  final bool rtl;

  const _BookChapterPicker({required this.bookNames, required this.rtl});

  @override
  State<_BookChapterPicker> createState() => _BookChapterPickerState();
}

class _BookChapterPickerState extends State<_BookChapterPicker> {
  int? _pickedBook;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: dirOf(widget.rtl),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child:
              _pickedBook == null ? _booksList() : _chaptersGrid(_pickedBook!),
        ),
      ),
    );
  }

  Widget _booksList() {
    final ot = List.generate(39, (i) => i);
    final nt = List.generate(27, (i) => i + 39);
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('انتخاب کتاب',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _header('عهد عتیق'),
        ...ot.map(_bookTile),
        _header('عهد جدید'),
        ...nt.map(_bookTile),
      ],
    );
  }

  Widget _header(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _bookTile(int index) => ListTile(
        title: Text(widget.bookNames[index]),
        trailing:
            Icon(widget.rtl ? Icons.chevron_left : Icons.chevron_right),
        onTap: () => setState(() => _pickedBook = index),
      );

  Widget _chaptersGrid(int bookIndex) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _pickedBook = null),
            ),
            Text(widget.bookNames[bookIndex],
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: chapterCounts[bookIndex],
            itemBuilder: (context, i) {
              final chapter = i + 1;
              return InkWell(
                onTap: () => Navigator.pop(context,
                    (bookIndex: bookIndex, chapter: chapter)),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(trNum(chapter, rtl: widget.rtl),
                      style: const TextStyle(fontSize: 18)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TranslationPicker extends StatelessWidget {
  final BibleTranslationInfo current;

  const _TranslationPicker({required this.current});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: dirOf(current.rtl),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('انتخاب ترجمه',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final t in availableTranslations)
              ListTile(
                title: Text(t.name),
                trailing: t.id == current.id
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(context, t),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
