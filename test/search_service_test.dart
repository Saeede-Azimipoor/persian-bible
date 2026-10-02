import 'package:flutter_test/flutter_test.dart';
import 'package:persian_bible/data/translations.dart';
import 'package:persian_bible/services/bible_service.dart';
import 'package:persian_bible/services/search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('جستجوی فارسی آیه‌های مرتبط را پیدا می‌کند', () async {
    final service = BibleService(assetDir: 'assets/bible/fa-opt');
    final search = SearchService(
      bible: service,
      translation: translationById('fa-opt'),
    );

    final results = await search.search('آسمان');

    expect(results, isNotEmpty);
    // پیدایش ۱:۱ باید جزو نتایج باشه
    expect(
      results.any((r) => r.bookIndex == 0 && r.chapter == 1 && r.verse == 1),
      isTrue,
    );
  });

  test('ي عربی با ی فارسی یکی حساب می‌شود', () async {
    final service = BibleService(assetDir: 'assets/bible/fa-opt');
    final search = SearchService(
      bible: service,
      translation: translationById('fa-opt'),
    );

    final faResults = await search.search('زمین');
    // زمين با ي عربی (U+064A)
    final arQuery = 'زم${String.fromCharCode(0x064A)}ن';
    final arResults = await search.search(arQuery);

    expect(faResults, isNotEmpty);
    expect(arResults.length, faResults.length);
  });

  test('جستجوی انگلیسی به بزرگی/کوچکی حروف حساس نیست', () async {
    final service = BibleService(assetDir: 'assets/bible/en-kjv');
    final search = SearchService(
      bible: service,
      translation: translationById('en-kjv'),
    );

    final lower = await search.search('heaven');
    final upper = await search.search('HEAVEN');

    expect(lower, isNotEmpty);
    expect(upper.length, lower.length);
  });
}
