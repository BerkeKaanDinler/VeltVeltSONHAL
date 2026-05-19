/// VELT — Theme Controller (ChangeNotifier-based)
/// Wrap the app with a ChangeNotifierProvider<ThemeController> and listen.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class ThemeController extends ChangeNotifier {
  ThemeController() { _load(); }

  static const _key = 'velt_theme';

  VeltTheme _current = VeltTheme.iron;
  VeltTheme get current => _current;

  /// In production, store this on the user's subscription state
  bool isPro = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      final found = VeltTheme.values.firstWhere(
        (t) => t.name == stored, orElse: () => VeltTheme.iron);
      _current = found;
      notifyListeners();
    }
  }

  Future<void> setTheme(VeltTheme theme) async {
    if (theme.isPro && !isPro) {
      // Caller should show paywall; refuse the change.
      return;
    }
    _current = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.name);
  }

  /// Toggle pro status (for demo / testing)
  void setPro(bool value) {
    isPro = value;
    notifyListeners();
  }
}
