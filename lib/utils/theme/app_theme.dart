import 'package:tic_tac_toe/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe/utils/theme/design_system.dart';

class AppTheme with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;

  bool startup = true;
  AppTheme({
    ThemeMode mode = ThemeMode.system,
  }) : _mode = mode {
    final modeString = preferences.getThemeMode();
    setModeString(modeString);
  }

  ///
  /// Set the theme mode of the app between light, dark and system.
  ///
  void setMode(ThemeMode m) {
    _mode = m;
    if (_mode == ThemeMode.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    } else if (_mode == ThemeMode.dark) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.restoreSystemUIOverlays();
    }
    preferences.setThemeMode(m.toString());
    notifyListeners();
  }

  ///
  /// Set the theme mode of the app from a string.
  ///
  void setModeString(String m) {
    switch (m) {
      case "ThemeMode.light":
        setMode(ThemeMode.light);
        break;
      case "ThemeMode.dark":
        setMode(ThemeMode.dark);
        break;
      case "ThemeMode.system":
      default:
        setMode(ThemeMode.system);
    }

    notifyListeners();
  }

  void switchMode() {
    if (_mode == ThemeMode.dark) {
      setMode(ThemeMode.light);
    } else {
      setMode(ThemeMode.dark);
    }
  }

  ///
  /// Helper method to access [DesignSystem].
  ///
  static DesignSystem of(BuildContext context) {
    return Theme.of(context).extension<DesignSystem>()!;
  }

  /// Helper method to access [StatusDesignSystem].
  ///
  static StatusDesignSystem status(BuildContext context) {
    return Theme.of(context).extension<StatusDesignSystem>()!;
  }

  ThemeData get theme => _theme;
  ThemeData get darkTheme => _darkTheme;

  ///
  /// Light theme of the app.
  ///
  final ThemeData _theme = ThemeData(
    textTheme: TextTheme(
      bodySmall: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
    ),
    extensions: <ThemeExtension<dynamic>>[
      StatusDesignSystem(),
      DesignSystem(
        primaryColor: Colors.indigo,
        secondaryColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    ],
  );

  static const Color _darkForeground = const Color.fromARGB(255, 210, 210, 210);

  ///
  /// Dark theme of the app.
  ///
  final ThemeData _darkTheme = ThemeData(
    textTheme: TextTheme(
      bodySmall: TextStyle(color: _darkForeground),
      bodyMedium: TextStyle(color: _darkForeground),
      bodyLarge: TextStyle(color: _darkForeground),
    ),
    extensions: <ThemeExtension<dynamic>>[
      StatusDesignSystem(),
      DesignSystem(
        primaryColor: Colors.indigo.shade900,
        secondaryColor: Colors.teal.shade900,
        foregroundColor: _darkForeground,
      ),
    ],
  );
}
