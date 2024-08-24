import 'package:dweb/dw_route.dart';
import 'package:dweb/dw_server.dart';

extension TranslateString on String {
  TString get tr {
    return TString(this);
  }

  // TString trParam(Map params) {
  //   var result = _find(this);

  //   for (var key in params.keys) {
  //     result = result.replaceAll("{$key}", params[key]);
  //   }

  //   return result;
  // }

  // TString trList(List list) {
  //   var result = _find(this);

  //   for (var i = 0; i < list.length; i++) {
  //     result = result.replaceAll("{$i}", list[i]);
  //   }

  //   return result;
  // }

  // TString _find(String key) {
  //   final ln = DwServer.language;
  //   var language = DwServer.appLanguages[ln] ?? DwServer.appLanguages['en'];
  //   if (language != null && language[key] != null) {
  //     key = language[key]!;
  //   }
  //   return key;
  // }
}

class TString {
  String key;
  TString(this.key);

  String write(WebRequest rq) {
    final ln = rq.getLanguage();
    var language = DwServer.appLanguages[ln] ?? DwServer.appLanguages['en'];
    if (language != null && language[key] != null) {
      return language[key]!;
    }
    return key;
  }

  String writeByLang(String ln) {
    var language = DwServer.appLanguages[ln] ?? DwServer.appLanguages['en'];
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
