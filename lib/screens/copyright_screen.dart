import 'package:flutter/material.dart';

/// صفحه‌ی حق نشر و انتساب‌ها: سازنده‌ی اپ، متن کتاب‌مقدس و فونت‌ها
class CopyrightScreen extends StatelessWidget {
  const CopyrightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('حق نشر')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: 'برنامه',
            body: '«کتاب مقدس»\n© 2026 سعیده عظیمی پور ',
            theme: theme,
          ),
          _Section(
            title: 'متن کتاب‌مقدس',
            body: 'ترجمه‌ی قدیم فارسی (1895) — مالکیت عمومی (Public Domain)\n'
                'King James Version (1611) — مالکیت عمومی (Public Domain)',
            theme: theme,
          ),
          _Section(
            title: 'فونت‌ها',
            body: 'Vazirmatn ‏،Noto Naskh Arabic ‏،Noto Nastaliq Urdu ‏،Noto Serif ‏،Lora و Merriweather\n'
                'تحت مجوز SIL Open Font License نسخه‌ی 1.1 منتشر شده‌اند.',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final ThemeData theme;

  const _Section({
    required this.title,
    required this.body,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyMedium?.copyWith(height: 2.0),
          ),
        ],
      ),
    );
  }
}
