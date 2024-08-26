import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_server.dart';

/// Extension on [String] to provide translation functionality.
extension TranslateString on String {
  /// Converts the string to a [TString] for translation.
  ///
  /// This extension method wraps the original string in a [TString] instance,
  /// which can be used to retrieve translations based on the current or specified language.
  ///
  /// Example:
  /// ```dart
  /// String greeting = 'hello';
  /// var translatedGreeting = greeting.tr;
  /// ```
  ///
  /// Returns a [TString] instance containing the original string as the translation key.
  TString get tr {
    return TString(this);
  }
}

/// Class representing a translatable string.
///
/// Use this class to handle translations of a string based on the current or specified language.
class TString {
  /// The translation key for this string.
  String key;

  /// Creates an instance of [TString] with the given translation key.
  ///
  /// [key] The translation key for this string.
  TString(this.key);

  /// Retrieves the translated string based on the current language from the [WebRequest].
  ///
  /// This method uses the current language from the [WebRequest] and looks up the translation
  /// in the application's language settings. If no translation is found, it returns the original key.
  ///
  /// Example:
  /// ```dart
  /// WebRequest request = ...; // Your web request object
  /// TString welcomeMessage = 'welcome'.tr;
  /// String translatedMessage = welcomeMessage.write(request);
  /// ```
  ///
  /// [rq] The [WebRequest] object that provides the current language context.
  ///
  /// Returns the translated string if found, otherwise returns the original key.
  String write(WebRequest rq) {
    final ln = rq.getLanguage();
    var language = WaServer.appLanguages[ln] ?? WaServer.appLanguages['en'];
    if (language != null && language[key] != null) {
      return language[key]!;
    }
    return key;
  }

  /// Retrieves the translated string based on a specified language code.
  ///
  /// This method allows specifying a language code to retrieve the translation from the
  /// application's language settings. If no translation is found, it returns the original key.
  ///
  /// Example:
  /// ```dart
  /// TString farewellMessage = 'goodbye'.tr;
  /// String translatedMessage = farewellMessage.writeByLang('fr');
  /// ```
  ///
  /// [ln] The language code (e.g., 'en', 'fr') to look up the translation.
  ///
  /// Returns the translated string if found, otherwise returns the original key.
  String writeByLang(String ln) {
    var language = WaServer.appLanguages[ln] ?? WaServer.appLanguages['en'];
    if (language != null && language[key] != null) {
      return language[key]!;
    }
    return key;
  }

  @override
  String toString() {
    return "TString type: '$key' Dont forget, using .write(rq) for TString";
  }
}
