import 'dart:io';

import 'package:dartweb/dw_console.dart';
import 'package:dartweb/dw_server.dart';
import 'package:dartweb/dw_tools.dart';
import 'package:dartweb/model_less.dart';
import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RenderViews {
  static render({
    required String path,
    Map<String, Object?> viewParams = const {},
    bool isFile = true,
    String language = 'en',
  }) {
    if (isFile) {
      File file = File(joinPaths([
        DwServer.config.widgetsPath,
        "$path.${DwServer.config.widgetsType}",
      ]));

      if (!file.existsSync()) {
        if (DwServer.config.isLocalDebug) {
          return "The path: ${file.path} is not correct!";
        } else {
          return "The path: ${file.uri.pathSegments.last} is not correct!";
        }
      }
    }

    var env = Environment(
        globals: _getGlobalEvents(language),
        autoReload: false,
        loader: FileSystemLoader(paths: <String>[DwServer.config.widgetsPath]),
        leftStripBlocks: false,
        trimBlocks: false,
        blockStart: DwServer.config.blockStart,
        blockEnd: DwServer.config.blockEnd,
        variableStart: DwServer.config.variableStart,
        variableEnd: DwServer.config.variableEnd,
        commentStart: DwServer.config.commentStart,
        commentEnd: DwServer.config.commentEnd,
        filters: {
          'dateFormat': (DateTime dt, String format) {
            return DateFormat(format).format(dt);
          },
        },
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
              if (DwServer.config.isLocalDebug) {
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
          DwServer.config.widgetsPath,
          "$path.${DwServer.config.widgetsType}",
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
    params['isLocalDebug'] = DwServer.config.isLocalDebug;

    params['render'] = () => 'TODO';
    params['param'] = {
      'timestamp_start': DateTime.now().millisecondsSinceEpoch,
    };

    var events = {
      'url': (String path) {
        return DwServer.config.url(path: path);
      },
      'urlParam': (String path, Map<String, String> params) {
        return _url(path, params: params);
      },
      'ln': language,
      'dir': 'language.${language}_dir'.tr.writeByLang(language),
      'langs': () {
        var langs = DwServer.appLanguages.keys;
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
    var pathRequest = DwServer.config.url(path: subPath);
    var uri = Uri.parse(pathRequest);
    uri = uri.resolve(subPath);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    /// Force to HTTPS for all URLs in Deployment
    /// When the app is localhost app does not load from HTTPS
    if (!DwServer.config.isLocalDebug) {
      uri = uri.replace(scheme: 'https');
    }
    var url = uri.toString();
    return url;
  }
}
