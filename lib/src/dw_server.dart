import 'dart:async';
import 'dart:io';
import 'package:dartweb/dw_server.dart';
import 'package:dartweb/src/render/web_request.dart';
import 'package:dartweb/src/router/route.dart';
import 'package:dartweb/src/router/web_route.dart';
import 'package:dartweb/src/tools/console.dart';
import 'package:dartweb/src/tools/multi_language/language.dart';
import 'package:dartweb/src/tools/path.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class DwServer {
  static final info = _Info();

  HttpServer? server;
  Future<WebRequest> Function(WebRequest rq)? onRequest;
  SocketManager? socketManager;
  bool get hasSocket => socketManager != null;
  mongo.Db? _db;
  final List<DwCron> crons = [];

  static Map<String, Map<String, String>> appLanguages = {};
  static late DwConfigs config;

  final List<Future<List<WebRoute>> Function(WebRequest rq)> _webRoutes = [];

  DwServer({
    required DwConfigs configs,
    this.onRequest,
  }) {
    DwServer.config = configs;
  }

  DwServer addRouting(Future<List<WebRoute>> Function(WebRequest rq) router) {
    _webRoutes.add(router);
    return this;
  }

  mongo.Db get db {
    if (_db == null) {
      connectMongoDb().then((value) => _db = value);
      throw ('Error DB is not running');
    }

    return _db!;
  }

  Future stop({bool force = true}) async {
    if (server != null) {
      await server!.close(force: force);
    }

    await db.close();
    server = null;
  }

  Future<HttpServer> start() {
    if (config.noStop) {
      return runZonedGuarded(() => _run(), (error, stack) {
        Console.e({
          'error': error,
          'stack': stack.toString().split("#"),
        });
      })!;
    } else {
      return _run();
    }
  }

  Future<HttpServer> _run() async {
    appLanguages = await MultiLanguage(config.languagePath).init();
    // Waiting to load database after a few secounds in live or staging
    if (!config.isLocalDebug) {
      await Future.delayed(Duration(seconds: 30));
    }

    _db = await connectMongoDb();

    server = await HttpServer.bind(
      config.ip,
      config.port,
    );

    server!.address;

    Console.p({
      'url': config.uri,
      'path': pathApp,
      'DB': {
        'path db': config.dbPath,
      }
    });

    await handleRequests(server!);
    return server!;
  }

  Future<void> handleRequests(HttpServer server) async {
    server.forEach((HttpRequest httpRequest) async {
      if (config.fakeDelay != 0) {
        await Future.delayed(Duration(seconds: config.fakeDelay)).then(
          (value) => Console.i("Server has fake delay"),
        );
      }

      WebRequest(httpRequest).init().then((WebRequest rq) {
        runZonedGuarded(() async {
          List<WebRoute> routing = [];

          if (config.dbConfig.enable) {
            if (_db == null) {
              _db = await connectMongoDb().onError((error, stackTrace) async {
                throw ("Error connect to DB");
              });
            } else if (!_db!.isConnected) {
              await _db!.open().onError((error, stackTrace) async {
                throw ("Error connect to DB");
              });
            }
          }

          for (var webRoute in _webRoutes) {
            routing.addAll(await webRoute(rq));
          }

          if (onRequest != null) {
            rq = await onRequest!(rq);
          }

          Route(
            routing: routing,
            rq: rq,
          ).handel();
        }, (error, StackTrace stack) async {
          Console.e({
            'error': error,
            'stack': stack.toString().split("#"),
          });

          rq.addParams({
            'error': error,
            'stack': stack.toString().split("#"),
          });

          await rq.renderError(502);

          await rq.writeAndClose('');
        });
      }).catchError((error, stack) {
        Console.e({
          'error': error,
          'stack': stack.toString().split("#"),
        });
      });
    });
  }

  Future<mongo.Db> connectMongoDb() async {
    var db = mongo.Db(config.dbConfig.link);
    if (config.dbConfig.enable) await db.open();
    return db;
  }

  void registerCron(DwCron cron) {
    crons.add(cron);
  }
}

class _Info {
  final String version = '1.0.0';
}
