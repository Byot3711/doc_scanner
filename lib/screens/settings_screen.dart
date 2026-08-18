import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<AppThemeNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            value: themeNotifier.themeMode == ThemeMode.dark,
            onChanged: (val) {
              themeNotifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info),
            child: Text('About'),
            applicationName: 'Doc Scanner Pro',
            applicationVersion: '6.0.0',
            applicationLegalese: '© 2024 Valentin Constantinescu\nhttps://github.com/Byot3711/doc_scanner',
          ),
        ],
      ),
    );
  }
}
