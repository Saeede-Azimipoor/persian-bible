// تعداد فصل‌های هر کتاب به ترتیب (۶۶ کتاب) — جمع کل: ۱۱۸۹ فصل
const List<int> chapterCounts = [
  50, 40, 27, 36, 34, 24, 21, 4, 31, 24,
  22, 25, 29, 36, 10, 13, 10, 42, 150, 31,
  12, 8, 66, 52, 5, 48, 12, 14, 3, 9,
  1, 4, 7, 3, 3, 3, 2, 14, 4, 28,
  16, 24, 21, 28, 16, 16, 13, 6, 6, 4,
  4, 5, 3, 6, 4, 3, 1, 13, 5, 5,
  3, 5, 1, 1, 1, 22,
];

int get totalChapters => chapterCounts.fold(0, (a, b) => a + b);

/// تبدیل شماره‌ی صفحه‌ی سراسری (۰ تا ۱۱۸۸) به (ایندکس کتاب، شماره‌ی فصل)
/// مثلاً صفحه‌ی ۰ یعنی پیدایش ۱، صفحه‌ی ۵۰ یعنی خروج ۱
({int bookIndex, int chapter}) pageToBookChapter(int page) {
  var rest = page;
  for (var i = 0; i < chapterCounts.length; i++) {
    if (rest < chapterCounts[i]) return (bookIndex: i, chapter: rest + 1);
    rest -= chapterCounts[i];
  }
  throw RangeError('صفحه‌ی نامعتبر: $page');
}

/// تبدیل (ایندکس کتاب، شماره‌ی فصل) به شماره‌ی صفحه‌ی سراسری
int bookChapterToPage(int bookIndex, int chapter) {
  var page = 0;
  for (var i = 0; i < bookIndex; i++) {
    page += chapterCounts[i];
  }
  return page + chapter - 1;
}
