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
