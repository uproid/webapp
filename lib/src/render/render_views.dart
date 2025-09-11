import 'dart:io';

import 'package:webapp/src/render/web_request.dart';
import 'package:webapp/wa_console.dart';
import 'package:webapp/wa_server.dart';
import 'package:webapp/wa_tools.dart';
import 'package:webapp/wa_model_less.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RenderViews {
  static String render({
    required String path,
    Map<String, Object?> viewParams = const {},
    bool isFile = true,
    String language = 'en',
  }) {
    if (isFile) {
      File file = File(joinPaths([
        WaServer.config.widgetsPath,
        "$path.${WaServer.config.widgetsType}",
      ]));

      if (!file.existsSync()) {
        if (WaServer.config.isLocalDebug) {
          return "The path: ${file.path} is not correct!";
        } else {
          return "The path: ${file.uri.pathSegments.last} is not correct!";
        }
      }
    }

    var env = Environment(
        globals: _getGlobalEvents(language),
        autoReload: false,
        loader: FileSystemLoader(paths: <String>[WaServer.config.widgetsPath]),
        leftStripBlocks: false,
        trimBlocks: false,
        blockStart: WaServer.config.blockStart,
        blockEnd: WaServer.config.blockEnd,
        variableStart: WaServer.config.variableStart,
        variableEnd: WaServer.config.variableEnd,
        commentStart: WaServer.config.commentStart,
        commentEnd: WaServer.config.commentEnd,
        filters: WebRequest.layoutFilters,
        getAttribute: (String key, dynamic object) {
          try {
            if (object is TString) {
              return object.writeByLang(language);
            }
            if (object is String && key == 'tr') {
              return object.tr.writeByLang(language);
            }

            if (object[key] != null) {
              if (object[key] is ObjectId) {
                (object[key] as ObjectId).oid;
              }
            }
            return object[key];
          } on NoSuchMethodError {
            Console.e({
              'error': {
                'object': object,
                'key': key,
                'error': 'The key "$key" on "$object" not found',
              }
            });

            if (object == null) {
              if (WaServer.config.isLocalDebug) {
                return 'The key "$key" on "$object" not found';
              } else {
                return null;
              }
            }

            return null;
          } catch (e) {
            Console.e({
              'error': {
                'object': object,
                'key': key,
                'error': e,
              }
            });
            return null;
          }
        });
    var params = viewParams;
    Template template;
    if (isFile) {
      template = env.getTemplate(File(
        joinPaths([
          WaServer.config.widgetsPath,
          "$path.${WaServer.config.widgetsType}",
        ]),
      ).path);
    } else {
      template = env.fromString(path);
    }
    var renderString = template.render(params);
    return renderString;
  }

  static Map<String, Object?> _getGlobalEvents(String language) {
    Map<String, Object?> params = {};
    params['isLocalDebug'] = WaServer.config.isLocalDebug;

    params['render'] = () => 'TODO';
    params['param'] = {
      'timestamp_start': DateTime.now().millisecondsSinceEpoch,
    };

    var events = {
      'url': (String path) {
        return WaServer.config.url(path: path);
      },
      'urlParam': (String path, Map<String, String> params) {
        return _url(path, params: params);
      },
      'ln': language,
      'dir': 'language.${language}_dir'.tr.writeByLang(language),
      'langs': () {
        var langs = WaServer.appLanguages.keys;
        var result = [];

        for (var lang in langs) {
          result.add({
            'code': lang,
            'label': 'language.${lang}_label'.tr.writeByLang(language),
            'contry': 'language.${lang}_contry'.tr.writeByLang(language),
          });
        }

        return result;
      },
    };

    params['\$e'] = LMap(events, def: null);
    params['\$t'] = (String text, [Object? params]) {
      if (params == null) {
        return text.tr.writeByLang(language);
      } else {
        // if (params is Map) {
        //   return text.trParam(params);
        // } else if (params is List) {
        //   return text.trList(params);
        // }
      }

      return text.tr.writeByLang(language);
    };

    var lmap = LMap(params, def: null);

    params['\$'] = lmap;
    return params;
  }

  static String _url(String subPath, {Map<String, String>? params}) {
    var pathRequest = WaServer.config.url(path: subPath);
    var uri = Uri.parse(pathRequest);
    uri = uri.resolve(subPath);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    /// Force to HTTPS for all URLs in Deployment
    /// When the app is localhost app does not load from HTTPS
    if (!WaServer.config.isLocalDebug) {
      uri = uri.replace(scheme: 'https');
    }
    var url = uri.toString();
    return url;
  }
}
