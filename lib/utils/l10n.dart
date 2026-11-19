import 'package:flutter/widgets.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

/// Translations for code that has no `BuildContext`: the PDF report, error
/// messages from services and providers, labels built in models. Widgets with a
/// context keep using `AppLocalizations.of(context)!`.
///
/// It follows the language the user picked: `main` sets it at startup and
/// `MyApp` updates it whenever the selected locale changes.
class L10n {
  L10n._();

  static const _supported = {'en', 'de', 'es', 'nl'};
  static Locale _locale = const Locale('en');

  static void setLocale(Locale locale) {
    _locale = _supported.contains(locale.languageCode) ? Locale(locale.languageCode) : const Locale('en');
  }

  static AppLocalizations get current => lookupAppLocalizations(_locale);
}

/// Shorthand for [L10n.current], for code without a `BuildContext`.
AppLocalizations get l10n => L10n.current;
