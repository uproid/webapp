import 'dart:io';

import 'package:dartweb/dw_route.dart';
import 'package:dartweb/dw_server.dart';
import 'package:dartweb/dw_tools.dart';
import 'package:dartweb/dw_ui.dart';
import '../example.dart';
import '../route/web_route.dart';

class HomeController extends DwController {
  HomeController(super.rq);

  @override
  Future<String> index() async {
    return renderTemplate('index');
  }

  Future<String> exampleForm() async {
    if (rq.method == RequestMethods.POST) {
      var loginForm = FormValidator(
        name: 'loginForm',
        rq: rq,
        fields: {
          'email': [
            (value) {
              return FieldValidateResult(
                success: value.toString().isEmail,
                error: 'Email is not valid',
              );
            },
            FieldValidator.requiredField(),
            FieldValidator.fieldLength(min: 5, max: 255)
          ],
          'password': [
            (value) {
              return FieldValidateResult(
                success: value.toString().isPassword,
                error:
                    'Password is not valid, it most has [Number/Char(Upper+Lower)/?@#\$!%]',
              );
            },
            FieldValidator.requiredField(),
            FieldValidator.fieldLength(min: 8, max: 255)
          ],
        },
      );

      var result = await loginForm.validateAndForm();
      var loginResult = false;

      if (result.result) {
        var email = rq.get<String>('email', def: '');
        var password = rq.get<String>('password', def: '');
        if (email == 'demo@example.com' && password == '@Test123') {
          loginResult = true;
        }
      }

      rq.addParams({
        'loginForm': result.form,
        'loginResult': loginResult,
      });
    }

    return renderTemplate('example/form');
  }

  Future<String> exampleCookie() async {
    return renderTemplate('example/cookie');
  }

  Future<String> exampleRoute() async {
    var allRoutes = await getWebRoute(rq);

    List<Map> convert(List<WebRoute> routes, String parentPath, hasAuth) {
      var result = <Map>[];

      for (final route in routes) {
        for (var method in route.methods) {
          var map = route.toMap(
            parentPath,
            hasAuth || route.auth != null,
            method,
          );
          result.addAll(map);
        }
        if (route.children.isNotEmpty) {
          result.addAll(
            convert(
              route.children,
              "$parentPath${route.path}",
              hasAuth || route.auth != null,
            ),
          );

          for (var epath in route.extraPath) {
            result.addAll(
              convert(
                route.children,
                "$parentPath$epath",
                hasAuth || route.auth != null,
              ),
            );
          }
        }
      }

      return result;
    }

    var webRoutes = convert(allRoutes, '', false);
    webRoutes.sort(
        (a, b) => a['fullPath'].toString().compareTo(b['fullPath'].toString()));

    rq.addParam('routes', webRoutes);
    return renderTemplate('example/route');
  }

  Future<String> exampleAddCookie() async {
    var name = rq.get<String>('name', def: '');
    var value = rq.get<String>('value', def: '');
    var safe = rq.get<bool>('safe', def: false);
    var action = rq.get<String>('action', def: 'add');

    if (action == 'delete') {
      rq.removeCookie(name);
    } else if (action == 'add' && name.isNotEmpty && value.isNotEmpty) {
      rq.addCookie(name, value, safe: safe);
    }

    return exampleCookie();
  }

  Future<String> exampleSocket() async {
    return renderTemplate('example/socket');
  }

  Future<String> renderTemplate(String widget) {
    rq.addParams({
      'title': 'logo.title',
      'year': DateTime.now().year,
    });

    rq.addParam('widget', widget);
    return rq.renderView(path: "template/home");
  }

  Future<String> indexApi() async => rq.renderData(
        data: {
          "message": "Hello World!!!",
          "success": true,
          "time": DateTime.now().toString(),
        },
      );

  Future<String> changeLanguage() async {
    var redirectTo = '/';
    var language = rq.uri.pathSegments.first;

    rq.changeLanguege(language);
    if (rq.uri.pathSegments.length > 1) {
      redirectTo = joinPaths(rq.uri.pathSegments.sublist(1));
    }

    return rq.redirect("/$redirectTo");
  }

  Future<String> socket() async {
    await socketManager.requestHandel(rq);
    return rq.renderSocket();
  }

  Future<String> info() async {
    Map dbInfo = server.db.isConnected ? await server.db.getBuildInfo() : {};
    var languageCount = [];
    DwServer.appLanguages.forEach((key, value) {
      languageCount.add("$key (${value.length})");
    });

    var collections = server.db.isConnected
        ? await server.db.modernListCollections().toList()
        : [];
    var collectionNames = collections.map((e) => e['name']);

    var headers = <String, List<String>>{};
    rq.headers.forEach((name, values) {
      headers[name] = values;
    });

    var serverInfo = <String, Object>{
      'Address': {
        'URL': rq.url(''),
        'URI': rq.uri.path,
        'Email default': configs.mailDefault,
        'IP': rq.getIP(),
      },
      'Headers': headers,
      'Versions': {
        'Version': configs.version,
        'Dart Web version': DwServer.info.version,
        'Dart version': Platform.version,
        'Mongo Version': dbInfo['version'] ?? 'Unknown',
      },
      'System': {
        'Number of processors': Platform.numberOfProcessors,
        'Oprating System':
            "${Platform.operatingSystem.toUpperCase()} ${Platform.operatingSystemVersion}",
      },
      'Database': {
        'DB name': configs.dbConfig.dbName,
        'Collections': collectionNames.join(', '),
      },
      'Date & Time': {
        'Idle Timeout': server.server!.idleTimeout,
        'Time': DateTime.now(),
        'Time stamp': DateTime.now().millisecondsSinceEpoch,
        'Time Zone Name': DateTime.now().timeZoneName,
      },
      'Language': {
        'Current language': rq.getLanguage(),
        'Languages Strings': languageCount.join(' , ').toUpperCase(),
      },
      'Server Info': {
        'Server Header': server.server!.serverHeader ?? 'Unknown',
        'Connection Count': server.server!.connectionsInfo().total,
        'Connection Active': server.server!.connectionsInfo().active,
        'Connection Closing': server.server!.connectionsInfo().closing,
        'Connection Idle': server.server!.connectionsInfo().idle,
      },
      'Cron Job': {
        'Cron count': server.crons.length,
        'Active Cron': server.crons
            .where((element) => element.status == CronStatus.running)
            .length,
        'Stoped Cron': server.crons
            .where((element) => element.status == CronStatus.stoped)
            .length,
        'Not started Cron': server.crons
            .where((element) => element.status == CronStatus.notStarted)
            .length,
      },
      'Socker IO Server': {
        'Socket Runing': server.hasSocket,
        'Socket online sessions': server.socketManager?.countClients ?? 0,
        'Socket online users': server.socketManager?.countUsers ?? 0,
      },
    };

    rq.addParam('server', serverInfo);
    if (rq.isApiEndpoint) {
      return rq.renderDataParam();
    }

    return renderTemplate('example/info');
  }
}
