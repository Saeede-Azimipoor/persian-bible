import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// اشاره به یه فصل — برای «نشانه» کردن جایی که می‌خوای بعداً ادامه بدی.
/// مستقل از ترجمه، مثل FavoriteRef.
@immutable
class BookmarkRef {
  final int bookNumber; // ۱ تا ۶۶
  final int chapter;

  const BookmarkRef({
    required this.bookNumber,
    required this.chapter,
  });

  String get key => '$bookNumber-$chapter';

  static BookmarkRef? fromKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return null;
    final nums = parts.map(int.tryParse).toList();
    if (nums.any((n) => n == null)) return null;
    return BookmarkRef(
      bookNumber: nums[0]!,
      chapter: nums[1]!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BookmarkRef && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class BookmarksService extends ChangeNotifier {
  static const _prefsKey = 'bookmarked_chapters';

  final Set<String> _keys = {};

  List<BookmarkRef> get all {
    final list =
        _keys.map(BookmarkRef.fromKey).whereType<BookmarkRef>().toList();
    list.sort((a, b) {
      final c = a.bookNumber.compareTo(b.bookNumber);
      return c != 0 ? c : a.chapter.compareTo(b.chapter);
    });
    return list;
  }

  bool isBookmarked(BookmarkRef ref) => _keys.contains(ref.key);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? [];
    _keys
      ..clear()
      ..addAll(stored.where((k) => BookmarkRef.fromKey(k) != null));
    notifyListeners();
  }

  Future<void> toggle(BookmarkRef ref) async {
    if (_keys.contains(ref.key)) {
      _keys.remove(ref.key);
    } else {
      _keys.add(ref.key);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _keys.toList());
  }
}
