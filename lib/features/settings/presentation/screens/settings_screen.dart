import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final hideCompleted = ref.watch(hideCompletedEventsProvider);
    final apiKey = ref.watch(openAiApiKeyProvider);
    final model = ref.watch(openAiModelProvider);

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
            const SizedBox(height: 20),
            Text('Smart Add', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('OpenAI API key'),
                    subtitle: Text(
                      apiKey == null ? 'Not set' : _maskApiKey(apiKey),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editOpenAiApiKey(context, ref, apiKey ?? ''),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Model'),
                    subtitle: Text(model),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editModel(context, ref, model),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Smart Add uses your OpenAI credits to draft event details from pasted text. Review every draft before saving.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editOpenAiApiKey(
    BuildContext context,
    WidgetRef ref,
    String initialValue,
  ) async {
    final controller = TextEditingController(text: initialValue);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('OpenAI API key'),
          content: TextField(
            controller: controller,
            autofocus: true,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API key',
              hintText: 'sk-...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await ref.read(openAiApiKeyProvider.notifier).setValue(controller.text);
    }
  }

  Future<void> _editModel(
    BuildContext context,
    WidgetRef ref,
    String initialValue,
  ) async {
    final controller = TextEditingController(text: initialValue);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Smart Add model'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Model',
              hintText: 'gpt-5-nano',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await ref.read(openAiModelProvider.notifier).setValue(controller.text);
    }
  }

  String _maskApiKey(String value) {
    if (value.length <= 10) {
      return 'Saved';
    }

    return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
  }
}
