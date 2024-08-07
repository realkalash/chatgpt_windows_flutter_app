import 'dart:io';

import 'package:fluent_gpt/log.dart';

import 'package:fluent_gpt/common/prefs/app_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:system_theme/system_theme.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'main.dart';

enum NavigationIndicators { sticky, end }

class AppTheme extends ChangeNotifier {
  AppTheme();

  /// Scheen resolution. Selectable by user. Default is null.
  Size? resolution;

  /// Percentage of the window opacity. Default is 5%.
  double windowEffectOpacity = 0.05;

  Future setResolution(Size? resolution, {bool notify = true}) async {
    this.resolution = resolution;
    if (resolution != null) {
      await AppCache.resolution.set('${resolution.width}x${resolution.height}');
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> init() async {
    final resolutionWidth = prefs?.getString('resolution')?.split('x')[0];
    final resolutionHeight = prefs?.getString('resolution')?.split('x')[1];
    if (resolutionWidth != null && resolutionHeight != null) {
      resolution =
          Size(double.parse(resolutionWidth), double.parse(resolutionHeight));
    }
    preventClose = prefs?.getBool('preventClose') ?? false;
  }

  bool preventClose = false;
  void togglePreventClose() {
    preventClose = !preventClose;
    AppCache.preventClose.set(preventClose);

    windowManager.setPreventClose(preventClose);
    notifyListeners();
  }

  AccentColor? _color;
  AccentColor get color => _color ?? systemAccentColor;
  set color(AccentColor color) {
    _color = color;
    notifyListeners();
  }

  bool isPinned = false;
  void togglePinMode() {
    isPinned = !isPinned;
    notifyListeners();
    windowManager.setAlwaysOnTop(isPinned);
    AppCache.alwaysOnTop.set(isPinned);
  }

  /// We should ignore the system theme mode!
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  bool get isDark => mode == ThemeMode.dark;

  WindowEffect _windowEffect =
      Platform.isLinux ? WindowEffect.disabled : WindowEffect.acrylic;
  WindowEffect get windowEffect => _windowEffect;

  /// By default is blue with 5% opacity
  static Color micaColor = Colors.blue.withOpacity(0.7);

  Color windowEffectColor = micaColor;

  Future<void> setEffect(WindowEffect effect) async {
    if (Platform.isLinux) {
      effect = WindowEffect.disabled;
      windowEffectOpacity = 0.0;
      windowEffectColor = Colors.transparent;
    }
    await Window.setEffect(
      effect: effect,
      color: windowEffectColor.withOpacity(windowEffectOpacity),
      dark: isDark,
    );
    _windowEffect = effect;
    log('Setting window effect to $effect');
    notifyListeners();
  }

  Future<void> setWindowEffectColor(Color color) async {
    windowEffectColor = color;
    log('Setting window effect color to $color');
    await setEffect(windowEffect);
  }

  Future<void> setWindowEffectOpacity(double opacity) async {
    windowEffectOpacity = opacity;
    log('Setting window effect opacity to $opacity');
    await setEffect(windowEffect);
  }

  TextDirection _textDirection = TextDirection.ltr;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection direction) {
    _textDirection = direction;
    notifyListeners();
  }

  Locale? _locale;
  Locale? get locale => _locale;
  set locale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }

  buildInfoBarDecoration(InfoBarSeverity severity) {
    if (severity == InfoBarSeverity.warning) {
      return BoxDecoration(
          color: Colors.yellow, borderRadius: BorderRadius.circular(8.0));
    } else if (severity == InfoBarSeverity.error) {
      return BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(8.0));
    }
    return BoxDecoration(
        color: Colors.black, borderRadius: BorderRadius.circular(8.0));
  }

  void toggleShowInDock() {
    AppCache.showAppInDock.set(!AppCache.showAppInDock.value!);
    windowManager.setSkipTaskbar(!AppCache.showAppInDock.value!);
    notifyListeners();
  }
}

AccentColor get systemAccentColor {
  if ((defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.android) &&
      !kIsWeb) {
    return AccentColor.swatch({
      'darkest': SystemTheme.accentColor.darkest,
      'darker': SystemTheme.accentColor.darker,
      'dark': SystemTheme.accentColor.dark,
      'normal': SystemTheme.accentColor.accent,
      'light': SystemTheme.accentColor.light,
      'lighter': SystemTheme.accentColor.lighter,
      'lightest': SystemTheme.accentColor.lightest,
    });
  }
  return Colors.blue;
}
