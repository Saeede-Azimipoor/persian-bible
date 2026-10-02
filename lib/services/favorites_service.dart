import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// اشاره به یه آیه — مستقل از ترجمه.
/// یه favorite هم نسخه‌ی فارسی رو پوشش می‌ده هم انگلیسی رو.
@immutable
class FavoriteRef {
  final int bookNumber; // ۱ تا ۶۶
  final int chapter;
  final int verse;

  const FavoriteRef({
    required this.bookNumber,
    required this.chapter,
    required this.verse,
  });

  String get key => '$bookNumber-$chapter-$verse';

  static FavoriteRef? fromKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final nums = parts.map(int.tryParse).toList();
    if (nums.any((n) => n == null)) return null;
    return FavoriteRef(
      bookNumber: nums[0]!,
      chapter: nums[1]!,
      verse: nums[2]!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FavoriteRef && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class FavoritesService extends ChangeNotifier {
  static const _prefsKey = 'favorite_verses';

  final Set<String> _keys = {};

  List<FavoriteRef> get all {
    final list = _keys
        .map(FavoriteRef.fromKey)
        .whereType<FavoriteRef>()
        .toList();
    list.sort((a, b) {
      final c = a.bookNumber.compareTo(b.bookNumber);
      if (c != 0) return c;
      final d = a.chapter.compareTo(b.chapter);
      return d != 0 ? d : a.verse.compareTo(b.verse);
    });
    return list;
  }

  bool isFavorite(FavoriteRef ref) => _keys.contains(ref.key);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? [];
    _keys
      ..clear()
      ..addAll(stored.map(_migrate).whereType<String>());
    notifyListeners();
  }

  /// مهاجرت از فرمت قدیمی که translationId داشت: 'fa-opt-1-2-3' -> '1-2-3'
  String? _migrate(String old) {
    for (final prefix in ['fa-opt-', 'en-kjv-']) {
      if (old.startsWith(prefix)) {
        return old.substring(prefix.length);
      }
    }
    return FavoriteRef.fromKey(old) != null ? old : null;
  }

  Future<void> toggle(FavoriteRef ref) async {
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
