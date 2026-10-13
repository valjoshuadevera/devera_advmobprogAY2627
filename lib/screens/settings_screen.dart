import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Enhancement 3: Dark/light mode switch is moved to the Settings page.
        child: SwitchListTile(
          title: const Text('Dark Mode'),
          value: themeProvider.isDark,
          onChanged: (_) => themeProvider.toggleTheme(),
        ),
      ),
    );
  }
}
