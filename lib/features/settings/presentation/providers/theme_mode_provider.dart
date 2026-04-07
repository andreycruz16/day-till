import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final box = Hive.box<dynamic>('settings');
  return ThemeModeNotifier(box);
});

final hideCompletedEventsProvider =
    StateNotifierProvider<HideCompletedEventsNotifier, bool>((ref) {
      final box = Hive.box<dynamic>('settings');
      return HideCompletedEventsNotifier(box);
    });

final openAiApiKeyProvider =
    StateNotifierProvider<OpenAiApiKeyNotifier, String?>((ref) {
      final box = Hive.box<dynamic>('settings');
      return OpenAiApiKeyNotifier(box);
    });

final openAiModelProvider = StateNotifierProvider<OpenAiModelNotifier, String>((
  ref,
) {
  final box = Hive.box<dynamic>('settings');
  return OpenAiModelNotifier(box);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._box) : super(_readThemeMode(_box));

  final Box<dynamic> _box;
  static const _themeModeKey = 'theme_mode';

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    final nextMode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _box.put(_themeModeKey, nextMode.name);
    state = nextMode;
  }

  static ThemeMode _readThemeMode(Box<dynamic> box) {
    final value = box.get(_themeModeKey);
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }
}

class HideCompletedEventsNotifier extends StateNotifier<bool> {
  HideCompletedEventsNotifier(this._box) : super(_readValue(_box));

  final Box<dynamic> _box;
  static const _hideCompletedKey = 'hide_completed_events';

  Future<void> setEnabled(bool enabled) async {
    await _box.put(_hideCompletedKey, enabled);
    state = enabled;
  }

  static bool _readValue(Box<dynamic> box) {
    return box.get(_hideCompletedKey) as bool? ?? false;
  }
}

class OpenAiApiKeyNotifier extends StateNotifier<String?> {
  OpenAiApiKeyNotifier(this._box) : super(_readValue(_box));

  final Box<dynamic> _box;
  static const _apiKeyKey = 'openai_api_key';

  Future<void> setValue(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await clear();
      return;
    }

    await _box.put(_apiKeyKey, trimmed);
    state = trimmed;
  }

  Future<void> clear() async {
    await _box.delete(_apiKeyKey);
    state = null;
  }

  static String? _readValue(Box<dynamic> box) {
    final value = box.get(_apiKeyKey) as String?;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }
}

class OpenAiModelNotifier extends StateNotifier<String> {
  OpenAiModelNotifier(this._box) : super(_readValue(_box));

  final Box<dynamic> _box;
  static const _modelKey = 'openai_model';
  static const defaultModel = 'gpt-5-nano';

  Future<void> setValue(String value) async {
    final trimmed = value.trim();
    final nextValue = trimmed.isEmpty ? defaultModel : trimmed;
    await _box.put(_modelKey, nextValue);
    state = nextValue;
  }

  static String _readValue(Box<dynamic> box) {
    final value = box.get(_modelKey) as String?;
    if (value == null || value.trim().isEmpty) {
      return defaultModel;
    }
    return value;
  }
}
