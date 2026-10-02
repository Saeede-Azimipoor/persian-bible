import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/translations.dart';
import '../models/bible.dart';
import '../services/bible_service.dart';
import '../services/favorites_service.dart';
import '../services/settings_service.dart';
import '../utils/format.dart';

/// یک نمونه‌ی مشترک برای هر ترجمه تا کش لود کتاب بین بازسازی‌ها حفظ بشه
final Map<String, BibleService> _bibleServices = {
  for (final t in availableTranslations)
    t.id: BibleService(assetDir: t.assetDir),
};

class FavoritesScreen extends StatelessWidget {
  final FavoritesService favorites;
  final SettingsService settings;
  final ValueChanged<FavoriteRef>? onSelect;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.settings,
    this.onSelect,
  });

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: ListenableBuilder(
        listenable: favorites,
        builder: (context, _) {
          final items = favorites.all;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('هنوز آیه‌ای رو نشونه نکردی',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('روی هر آیه نگه دار تا به علاقه‌مندی‌ها اضافه بشه',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final ref = items[i];
              return _FavoriteTile(
                ref: ref,
                settings: settings,
                onTap: onSelect == null ? null : () => onSelect!(ref),
              );
            },
          );
        },
      ),
    ),
  );
}
}

class _FavoriteTile extends StatelessWidget {
  final FavoriteRef ref;
  final SettingsService settings;
  final VoidCallback? onTap;

  const _FavoriteTile(
      {required this.ref, required this.settings, this.onTap});

  @override
  Widget build(BuildContext context) {
    final translations = availableTranslations;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<BibleBook>>(
            future: Future.wait([
              for (final t in translations)
                _bibleServices[t.id]!.loadBook(ref.bookNumber),
            ]),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text('خطا در بارگذاری',
                    style: Theme.of(context).textTheme.bodyMedium);
              }
              if (!snap.hasData) {
                return const SizedBox(
                  height: 96,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final blocks = <Widget>[];
              for (var i = 0; i < translations.length; i++) {
                final t = translations[i];
                final book = snap.data![i];
                final verse = book.chapters[ref.chapter - 1].verses
                    .firstWhere((v) => v.number == ref.verse);
                if (i > 0) blocks.add(const Divider(height: 28));
                blocks.add(_TranslationBlock(
                  translation: t,
                  ref: ref,
                  text: verse.text,
                  settings: settings,
                ));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: blocks,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TranslationBlock extends StatelessWidget {
  final BibleTranslationInfo translation;
  final FavoriteRef ref;
  final String text;
  final SettingsService settings;

  const _TranslationBlock({
    required this.translation,
    required this.ref,
    required this.text,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final t = translation;
    final names = bookNamesFor(t);
    final title =
        '${names[ref.bookNumber - 1]} ${trNum(ref.chapter, rtl: t.rtl)}:${trNum(ref.verse, rtl: t.rtl)}';
    return Column(
      crossAxisAlignment:
          t.rtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textDirection: t.rtl ? TextDirection.rtl : TextDirection.ltr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textDirection: t.rtl ? TextDirection.rtl : TextDirection.ltr,
          textAlign: t.rtl ? TextAlign.right : TextAlign.left,
          style: _verseStyle(settings, t.rtl),
        ),
      ],
    );
  }
}

TextStyle _verseStyle(SettingsService s, bool rtl) {
  final size = s.fontSize;
  if (rtl) {
    switch (s.faFont) {
      case 'nastaliq':
        return GoogleFonts.notoNastaliqUrdu(fontSize: size, height: 2.4);
      case 'vazir':
        return GoogleFonts.vazirmatn(fontSize: size, height: 2.0);
      case 'naskh':
      default:
        return GoogleFonts.notoNaskhArabic(fontSize: size, height: 2.0);
    }
  }
  switch (s.enFont) {
    case 'lora':
      return GoogleFonts.lora(fontSize: size, height: 1.9);
    case 'merriweather':
      return GoogleFonts.merriweather(fontSize: size, height: 1.9);
    case 'noto-serif':
    default:
      return GoogleFonts.notoSerif(fontSize: size, height: 1.9);
  }
}
