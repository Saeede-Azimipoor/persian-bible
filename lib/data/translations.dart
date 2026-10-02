import 'english_book_names.dart';
import 'persian_book_names.dart';

/// اطلاعات هر ترجمه
class BibleTranslationInfo {
  final String id;
  final String name; // اسم نمایشی
  final String shortName; // اسم کوتاه برای قرص بالای صفحه
  final String assetDir; // پوشه‌ی فایل‌های JSON
  final bool rtl; // جهت متن: فارسی راست‌به‌چپ، انگلیسی چپ‌به‌راست

  const BibleTranslationInfo({
    required this.id,
    required this.name,
    required this.shortName,
    required this.assetDir,
    required this.rtl,
  });
}

const List<BibleTranslationInfo> availableTranslations = [
  BibleTranslationInfo(
    id: 'fa-opt',
    name: 'ترجمه‌ی قدیم (فارسی)',
    shortName: 'OPT',
    assetDir: 'assets/bible/fa-opt',
    rtl: true,
  ),
  BibleTranslationInfo(
    id: 'en-kjv',
    name: 'King James Version (English)',
    shortName: 'KJV',
    assetDir: 'assets/bible/en-kjv',
    rtl: false,
  ),
];

BibleTranslationInfo translationById(String id) =>
    availableTranslations.firstWhere(
      (t) => t.id == id,
      orElse: () => availableTranslations.first,
    );

/// اسم کتاب‌ها به زبان خودِ ترجمه
List<String> bookNamesFor(BibleTranslationInfo t) =>
    t.rtl ? persianBookNames : englishBookNames;

List<String> bookNamesForId(String id) =>
    bookNamesFor(translationById(id));
