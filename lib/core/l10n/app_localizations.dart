import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'strings_en.dart';
import 'strings_hi.dart';
import 'strings_ta.dart';

/// Lightweight localization: key -> string with {0}, {1} placeholders.
/// Falls back to English, then to the key itself. Add a language by adding a
/// strings_xx.dart map and listing it below.
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('ta')];
  static const delegate = _Delegate();

  static const _tables = <String, Map<String, String>>{
    'en': enStrings,
    'hi': hiStrings,
    'ta': taStrings,
  };

  static const languageNames = {'en': 'English', 'hi': 'हिन्दी', 'ta': 'தமிழ்'};

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ?? const AppLocalizations(Locale('en'));

  /// English text for a key. The mock assistant backend understands English, so chips send this.
  static String en(String key) => enStrings[key] ?? key;

  String t(String key, [List<Object> args = const []]) {
    var s = _tables[locale.languageCode]?[key] ?? enStrings[key] ?? key;
    for (var i = 0; i < args.length; i++) {
      s = s.replaceAll('{$i}', '${args[i]}');
    }
    return s;
  }
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();
  @override
  bool isSupported(Locale locale) => AppLocalizations._tables.containsKey(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(locale));
  @override
  bool shouldReload(_Delegate old) => false;
}

extension L10nCtx on BuildContext {
  /// Translate a key: `context.t('home.greeting', ['Nitin'])`.
  String t(String key, [List<Object> args = const []]) => AppLocalizations.of(this).t(key, args);
}
