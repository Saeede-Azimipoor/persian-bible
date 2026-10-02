class Verse {
  final int number;
  final String text;
  final String? heading;

  Verse({required this.number, required this.text, this.heading});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: int.parse(json['verse'].toString()),
      text: (json['text'] as String?) ?? '',
      heading: json['heading'] as String?,
    );
  }
}

class Chapter {
  final int number;
  final String? heading;
  final List<Verse> verses;

  Chapter({required this.number, this.heading, required this.verses});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final versesJson = json['verses'] as List;
    return Chapter(
      number: int.parse(json['chapter'].toString()),
      heading: json['heading'] as String?,
      verses: versesJson
          .map((v) => Verse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BibleBook {
  final String name;
  final List<Chapter> chapters;

  BibleBook({required this.name, required this.chapters});

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    final chaptersJson = json['chapters'] as List;
    return BibleBook(
      name: (json['name'] as String?) ?? '',
      chapters: chaptersJson
          .map((c) => Chapter.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  int get chapterCount => chapters.length;
}
