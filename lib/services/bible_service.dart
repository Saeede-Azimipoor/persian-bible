import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/bible.dart';

class BibleService {
  final String assetDir;

  BibleService({required this.assetDir});

  // مخفف‌های ۶۶ کتاب به ترتیب — برای ساختن اسم فایل (مثل 01-Gen.json)
  static const List<String> _abbreviations = [
    'Gen', 'Exod', 'Lev', 'Num', 'Deut',
    'Josh', 'Judg', 'Ruth', '1Sam', '2Sam',
    '1Kgs', '2Kgs', '1Chr', '2Chr', 'Ezra',
    'Neh', 'Esth', 'Job', 'Ps', 'Prov',
    'Eccl', 'Song', 'Isa', 'Jer', 'Lam',
    'Ezek', 'Dan', 'Hos', 'Joel', 'Amos',
    'Obad', 'Jonah', 'Mic', 'Nah', 'Hab',
    'Zeph', 'Hag', 'Zech', 'Mal', 'Matt',
    'Mark', 'Luke', 'John', 'Acts', 'Rom',
    '1Cor', '2Cor', 'Gal', 'Eph', 'Phil',
    'Col', '1Thess', '2Thess', '1Tim', '2Tim',
    'Titus', 'Phlm', 'Heb', 'Jas', '1Pet',
    '2Pet', '1John', '2John', '3John', 'Jude',
    'Rev',
  ];

  // کش: هر کتاب فقط یک‌بار از روی حافظه خوانده می‌شود
  final Map<int, BibleBook> _cache = {};

  String _fileName(int bookNumber) {
    final num = bookNumber.toString().padLeft(2, '0');
    return '$num-${_abbreviations[bookNumber - 1]}.json';
  }

  Future<BibleBook> loadBook(int bookNumber) async {
    if (_cache.containsKey(bookNumber)) return _cache[bookNumber]!;
    final raw = await rootBundle.loadString('$assetDir/${_fileName(bookNumber)}');
    final book = BibleBook.fromJson(json.decode(raw));
    _cache[bookNumber] = book;
    return book;
  }
  Future<List<BibleBook>>? _allBooksFuture;

/// لود هر ۶۶ کتاب — فقط دفعه‌ی اول واقعاً می‌خونه، بعدش از کش
Future<List<BibleBook>> loadAllBooks() {
  return _allBooksFuture ??= Future.wait(
    List.generate(66, (i) => loadBook(i + 1)),
  );
}

}
