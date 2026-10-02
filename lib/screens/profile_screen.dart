import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'copyright_screen.dart';
import '../services/settings_service.dart';

class ProfileScreen extends StatelessWidget {
  final SettingsService settings;

  const ProfileScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('ظاهر'),
          Center(
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest),
                  label: Text('سیستم'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('روشن'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('تیره'),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) =>
                  settings.setThemeMode(s.first),
            ),
          ),
          const SizedBox(height: 24),
          _section('فونت فارسی'),
          for (final e in SettingsService.faFontNames.entries)
            RadioListTile<String>(
              // اسم هر فونت با خودش نوشته می‌شه!
              title: Text(e.value,
                  style: SettingsService.previewStyle(
                      rtl: true, fontId: e.key)),
              value: e.key,
              groupValue: settings.faFont,
              onChanged: (v) =>
                  v != null ? settings.setFaFont(v) : null,
            ),
          const SizedBox(height: 8),
          _section('فونت انگلیسی'),
          for (final e in SettingsService.enFontNames.entries)
            RadioListTile<String>(
              title: Text(e.value,
                  style: SettingsService.previewStyle(
                      rtl: false, fontId: e.key)),
              value: e.key,
              groupValue: settings.enFont,
              onChanged: (v) =>
                  v != null ? settings.setEnFont(v) : null,
            ),
          const SizedBox(height: 24),
          _section('اندازه‌ی متن'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: 16,
                  max: 30,
                  divisions: 14,
                  value: settings.fontSize,
                  label: '${settings.fontSize.round()}',
                  onChanged: settings.setFontSize,
                ),
              ),
              SizedBox(
                width: 36,
                child: Text('${settings.fontSize.round()}',
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('پیش‌نمایش',
                      style:
                          Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Text(
                    'در ابتدا خدا آسمان و زمین را آفرید.',
                    style: settings.verseStyle(rtl: true),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'In the beginning God created the heaven and the earth.',
                    style: settings.verseStyle(rtl: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _section('درباره'),
          const Text(
              'Persian Bible \n کاملاً آفلاین'),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('تماس با سازنده'),
              subtitle:
                  const SelectableText('saeedeazimiap@gmail.com'),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(
                      text: 'saeedeazimiap@gmail.com'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ایمیل کپی شد 📋'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.copyright_outlined),
              title: const Text('حق نشر'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CopyrightScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
      );
}
