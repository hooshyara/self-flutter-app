import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  static const List<Locale> supportedLocales = [
    Locale('fa'),
    Locale('en'),
  ];

  Locale _locale = const Locale('fa');

  Locale get locale => _locale;

  bool get isPersian => _locale.languageCode == 'fa';

  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = isPersian ? const Locale('en') : const Locale('fa');
    notifyListeners();
  }
}