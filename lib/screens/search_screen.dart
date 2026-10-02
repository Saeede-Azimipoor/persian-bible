import 'dart:async';

import 'package:flutter/material.dart';

import '../data/translations.dart';
import '../services/bible_service.dart';
import '../services/favorites_service.dart'; // برای FavoriteRef
import '../services/search_service.dart';
import '../services/settings_service.dart';
import '../utils/format.dart';

class SearchScreen extends StatefulWidget {
  final BibleService service;
  final BibleTranslationInfo translation;
  final SettingsService settings;

  const SearchScreen({
    super.key,
    required this.service,
    required this.translation,
    required this.settings,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchService _search;
  final _controller = TextEditingController();
  Timer? _debounce;
  Future<List<SearchResult>>? _resultsFuture;
  bool _preparing = false;

  @override
  void initState() {
    super.initState();
    _search = SearchService(
        bible: widget.service, translation: widget.translation);
    _controller.addListener(() => setState(() {}));
    _prepare();
  }

  Future<void> _prepare() async {
    setState(() => _preparing = true);
    await widget.service.loadAllBooks();
    if (mounted) setState(() => _preparing = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    final query = q.trim();
    if (query.isEmpty) {
      setState(() => _resultsFuture = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _resultsFuture = _search.search(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final rtl = widget.translation.rtl;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _onQueryChanged,
            textDirection: dirOf(rtl),
            decoration: InputDecoration(
              hintText: rtl ? 'جستجو در ترجمه‌ی قدیم…' : 'Search KJV…',
              border: InputBorder.none,
            ),
          ),
          actions: [
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _onQueryChanged('');
                },
              ),
          ],
        ),
        body: _buildBody(rtl),
      ),
    );
  }

  Widget _buildBody(bool rtl) {
    if (_preparing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال آماده‌سازی جستجو…'),
          ],
        ),
      );
    }
    final f = _resultsFuture;
    if (f == null) {
      return Center(
        child: Text(
          rtl ? 'عبارت مورد نظرت رو بنویس 🔍' : 'Type to search 🔍',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    return FutureBuilder(
      future: f,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطا: ${snapshot.error}'));
        }
        final results = snapshot.data!;
        if (results.isEmpty) {
          return const Center(child: Text('نتیجه‌ای پیدا نشد'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${trNum(results.length, rtl: true)} نتیجه',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }
            return _resultTile(results[i - 1], rtl);
          },
        );
      },
    );
  }

  Widget _resultTile(SearchResult r, bool rtl) {
    final names = bookNamesFor(widget.translation);
    final label =
        '${names[r.bookIndex]} ${trNum(r.chapter, rtl: rtl)}:${trNum(r.verse, rtl: rtl)}';
    final baseStyle =
        widget.settings.verseStyle(rtl: rtl, fontSize: 17);
    final hlStyle = baseStyle.copyWith(
      backgroundColor: Colors.amber.withValues(alpha: 0.35),
      fontWeight: FontWeight.bold,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pop(
          context,
          FavoriteRef(
            bookNumber: r.bookIndex + 1,
            chapter: r.chapter,
            verse: r.verse,
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const SizedBox(height: 8),
              Directionality(
                textDirection: dirOf(rtl),
                child: Text.rich(
                  _highlighted(r.text, r.matches, baseStyle, hlStyle),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _highlighted(String text, List<(int, int)> matches,
      TextStyle base, TextStyle hl) {
    final children = <TextSpan>[];
    var pos = 0;
    for (final (s, e) in matches) {
      if (s > pos) children.add(TextSpan(text: text.substring(pos, s)));
      children.add(TextSpan(text: text.substring(s, e), style: hl));
      pos = e;
    }
    if (pos < text.length) {
      children.add(TextSpan(text: text.substring(pos)));
    }
    return TextSpan(style: base, children: children);
  }
}
