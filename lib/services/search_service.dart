import '../data/translations.dart';
import 'bible_service.dart';

/// یه آیه‌ی پیداشده در جستجو
class SearchResult {
  final int bookIndex; // ۰ تا ۶۵
  final int chapter;
  final int verse;
  final String text; // متن اصلی آیه
  final List<(int, int)> matches; // بازه‌های هایلایت توی متن اصلی

  const SearchResult({
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.matches,
  });
}

class _Normalized {
  final String text;
  final List<int> indexMap; // ایندکس نرمال‌شده -> ایندکس متن اصلی
  const _Normalized(this.text, this.indexMap);
}

/// یکدست‌سازی متن برای جستجو:
/// ی/ك عربی به فارسی، ة به ه، حذف اعراب و نیم‌فاصله، انگلیسی: lowercase.
/// فقط جایگزینی ۱به۱ یا حذف انجام می‌شه تا نگاشت ایندکس‌ها برای هایلایت دقیق بمونه
_Normalized _normalize(String input, {required bool rtl}) {
  final buf = StringBuffer();
  final map = <int>[];
  final src = rtl ? input : input.toLowerCase();
  for (var i = 0; i < src.length; i++) {
    var ch = src[i];
    if (rtl) {
      if (ch == 'ي') {
        ch = 'ی';
      } else if (ch == 'ك') {
        ch = 'ک';
      } else if (ch == 'ة') {
        ch = 'ه';
      } else if (ch == '‌') {
        continue; // نیم‌فاصله
      }
      final code = ch.codeUnitAt(0);
      if ((code >= 0x064B && code <= 0x0652) || code == 0x0670) {
        continue; // اعراب
      }
    }
    buf.write(ch);
    map.add(i);
  }
  return _Normalized(buf.toString(), map);
}

class SearchService {
  final BibleService bible;
  final BibleTranslationInfo translation;

  SearchService({required this.bible, required this.translation});

  /// جستجو در کل کتاب مقدس — حداکثر [limit] نتیجه
  Future<List<SearchResult>> search(String query, {int limit = 200}) async {
    final books = await bible.loadAllBooks();
    final rtl = translation.rtl;
    final nq = _normalize(query.trim(), rtl: rtl);
    if (nq.text.isEmpty) return [];

    final results = <SearchResult>[];
    outer:
    for (var bi = 0; bi < books.length; bi++) {
      final chapters = books[bi].chapters;
      for (var ci = 0; ci < chapters.length; ci++) {
        for (final verse in chapters[ci].verses) {
          final nv = _normalize(verse.text, rtl: rtl);
          final matches = <(int, int)>[];
          var from = 0;
          while (true) {
            final idx = nv.text.indexOf(nq.text, from);
            if (idx < 0) break;
            // برگردوندن به ایندکس‌های متن اصلی برای هایلایت
            final s = nv.indexMap[idx];
            final e = nv.indexMap[idx + nq.text.length - 1] + 1;
            matches.add((s, e));
            from = idx + 1;
          }
          if (matches.isNotEmpty) {
            results.add(SearchResult(
              bookIndex: bi,
              chapter: ci + 1,
              verse: verse.number,
              text: verse.text,
              matches: matches,
            ));
            if (results.length >= limit) break outer;
          }
        }
      }
    }
    return results;
  }
}
