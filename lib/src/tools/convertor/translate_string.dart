import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_server.dart';

extension TranslateString on String {
  TString get tr {
    return TString(this);
  }
}

class TString {
  String key;
  TString(this.key);

  String write(WebRequest rq) {
    final ln = rq.getLanguage();
    var language = WaServer.appLanguages[ln] ?? WaServer.appLanguages['en'];
    if (language != null && language[key] != null) {
      return language[key]!;
    }
    return key;
  }

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
