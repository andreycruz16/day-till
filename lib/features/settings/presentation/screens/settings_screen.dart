import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final hideCompleted = ref.watch(hideCompletedEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile.adaptive(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use a darker theme throughout the app'),
                value: isDarkMode,
                onChanged: (enabled) {
                  ref.read(themeModeProvider.notifier).setDarkMode(enabled);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Homepage', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile.adaptive(
                title: const Text('Hide completed events'),
                subtitle: const Text(
                  'Hide events that have already passed from the home list',
                ),
                value: hideCompleted,
                onChanged: (enabled) {
                  ref
                      .read(hideCompletedEventsProvider.notifier)
                      .setEnabled(enabled);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
