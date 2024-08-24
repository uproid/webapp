import 'dart:convert';
import 'dart:io';
import 'package:dartweb/dw_server.dart';
import 'package:dartweb/src/router/dw_controller.dart';

class IncludeJsController extends DwController {
  IncludeJsController(super.rq);

  @override
  Future<String> index({Map<String, Object?> params = const {}}) async {
    var allLanguage = rq.get<bool>('allLanguage', def: false);
    Map<String, Object?> global = {
      'time': DateTime.now().toString(),
      'language': allLanguage
          ? DwServer.appLanguages
          : DwServer.appLanguages[rq.getLanguage()] ?? {},
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
