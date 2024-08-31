import 'dart:convert';
import 'dart:io';
import 'package:webapp/wa_server.dart';
import 'package:webapp/src/router/wa_controller.dart';

/// A controller responsible for injecting JavaScript for client-side operations.
///
/// This controller generates a JavaScript snippet that contains global configuration
/// and translation functions. The generated JavaScript can be used on the client-side
/// to handle localization and dynamic URL generation.
class IncludeJsController extends WaController {
  /// Creates an instance of [IncludeJsController].
  ///
  /// The [rq] parameter is required to initialize the base class [WaController].
  IncludeJsController(super.rq);

  /// Handles the inclusion of JavaScript in the response.
  ///
  /// This method generates a JavaScript snippet that includes:
  /// - Global configuration parameters such as the current time, language settings,
  ///   and a timestamp.
  /// - A translation function (`tr`) to fetch localized strings.
  /// - A translation parameter function (`trParam`) to replace placeholders in the
  ///   localized strings with provided parameters.
  /// - A URL path function (`urlPath`) to generate URLs based on the current request's URL.
  ///
  /// The [params] parameter allows additional key-value pairs to be included in the
  /// global configuration.
  ///
  /// Returns a [Future<String>] that resolves to a JavaScript snippet as a string.
  ///
  /// The content type of the response is set to `text/javascript`.
  @override
  Future<String> index({Map<String, Object?> params = const {}}) async {
    var allLanguage = rq.get<bool>('allLanguage', def: false);
    Map<String, Object?> global = {
      'time': DateTime.now().toString(),
      'language': allLanguage
          ? WaServer.appLanguages
          : WaServer.appLanguages[rq.getLanguage()] ?? {},
      'ln': rq.getLanguage(),
      'timestamp': DateTime.now().microsecondsSinceEpoch,
      'url': rq.url('/'),
      ...params,
    };

    var jsonString = json.encode(global);
    String requestScript = '''
;DS={
  global:$jsonString,
  tr: function (path) {
    return request.language[path];
  },
  trParam: function (path, params) {
    var result = request.language[path];
    for (let key in params) {
      result = result.replace(`{\${key}}`, params[key]);
    }
    return result;
  },
  urlPath : function(path){
    return '${rq.url('/')}'+path;
  }
};
''';
    var content = requestScript.replaceAll('\n', '').replaceAll('\t', '');

    return rq.renderString(
      text: content,
      contentType: ContentType('text', 'javascript', charset: 'utf-8'),
    );
  }
}
