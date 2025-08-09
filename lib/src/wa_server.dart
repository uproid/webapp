import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:capp/capp.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:webapp/src/db/mysql/mysql_migration.dart';
import 'package:webapp/src/tools/convertor/string_validator.dart';
import 'package:webapp/wa_server.dart';
import 'package:webapp/src/render/web_request.dart';
import 'package:webapp/src/router/route.dart';
import 'package:webapp/src/router/web_route.dart';
import 'package:webapp/src/tools/console.dart';
import 'package:webapp/src/tools/multi_language/language.dart';
import 'package:webapp/src/tools/path.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

/// A class that represents the web server for handling HTTP requests and database operations.
///
/// The `WaServer` class is responsible for initializing and starting the web server, managing HTTP requests,
/// handling routes, connecting to MongoDB, and managing scheduled tasks (cron jobs). It also provides methods
/// for adding routing functions and stopping the server.
class WaServer {
  /// A list of command-line arguments passed to the server.
  List<String> _args = [];

  /// Provides information about the version of the server.
  static final info = _Info();

  /// The HTTP server instance.
  HttpServer? server;

  /// A function that takes a [WebRequest] and returns a [Future] containing the modified [WebRequest].
  Future<WebRequest> Function(WebRequest rq)? onRequest;

  /// Manages WebSocket connections.
  SocketManager? socketManager;

  /// A boolean indicating if the server has an active WebSocket manager.
  bool get hasSocket => socketManager != null;

  /// The MongoDB database instance.
  mongo.Db? _db;

  /// The MySQL database connection instance.
  MySQLConnection? _mysqlDb;

  /// A list of [WaCron] instances representing scheduled tasks.
  final List<WaCron> crons = [];

  /// A map of application languages, where the key is the language code and the value is a map of strings.
  static Map<String, Map<String, String>> appLanguages = {};

  /// The server configuration.
  static late WaConfigs config;

  /// A list of functions that return a [Future] containing a list of [WebRoute] based on the [WebRequest].
  final List<Future<List<WebRoute>> Function(WebRequest rq)> _webRoutes = [];

  /// Creates an instance of [WaServer] with the specified [WaConfigs] and an optional [onRequest] function.
  ///
  /// The [configs] parameter is required and provides the configuration for the server.
  /// The [onRequest] parameter, if provided, allows customization of the [WebRequest] before handling.
  WaServer({
    required WaConfigs configs,
    this.onRequest,
  }) {
    WaServer.config = configs;
  }

  /// Adds a routing function to the server.
  ///
  /// The [router] function returns a [Future] containing a list of [WebRoute] based on the provided [WebRequest].
  /// This allows for dynamic routing based on the request.
  ///
  /// Returns the [WaServer] instance to allow method chaining.
  WaServer addRouting(Future<List<WebRoute>> Function(WebRequest rq) router) {
    _webRoutes.add(router);
    return this;
  }

  /// Get routing list of Server
  /// Here you can get all routing of server that added to server
  /// Returns a list of [WebRoute] instances.
  Future<List<WebRoute>> getAllRoutes(WebRequest rq) async {
    List<WebRoute> routing = [];
    for (var webRoute in _webRoutes) {
      routing.addAll(await webRoute(rq));
    }
    return routing;
  }

  /// Gets the MongoDB database instance.
  ///
  /// If the database is not connected, this method will attempt to connect to MongoDB.
  /// Throws an exception if the database is not running.
  mongo.Db get db {
    if (_db == null) {
      connectMongoDb().then((value) => _db = value);
      throw ('Error DB is not running');
    }

    return _db!;
  }

  MySQLConnection get mysqlDb {
    if (_mysqlDb == null || !_mysqlDb!.connected) {
      connectMysqlDb();
    }
    return _mysqlDb!;
  }

  /// Stops the server and closes the database connection.
  ///
  /// The [force] parameter specifies whether to forcefully close the server.
  Future stop({bool force = true}) async {
    if (server != null) {
      await server!.close(force: force);
    }

    await db.close();
    server = null;
  }

  /// Starts the server and binds it to the specified IP and port.
  ///
  /// If [config.noStop] is true, the server will run within a guarded zone to handle errors.
  /// Otherwise, it runs normally.
  ///
  /// Returns a [Future] containing the [HttpServer] instance.
  /// If [awaitCommands] is true, it will also handle command-line inputs.
  Future<HttpServer> start([List<String>? args, bool awaitCommands = true]) {
    this._args = args ?? [];
    if (config.noStop) {
      return runZonedGuarded(() => _run(args, awaitCommands: awaitCommands),
          (error, stack) {
        Console.e({
          'error': error,
          'stack': stack.toString().split("#"),
        });
      })!;
    } else {
      return _run(args);
    }
  }

  /// Initializes and starts the HTTP server, sets up the database connection, and handles requests.
  ///
  /// This method is called internally by [start]. It waits for the database to load and sets up request handling.
  ///
  /// Returns a [Future] containing the [HttpServer] instance.
  Future<HttpServer> _run(List<String>? args,
      {bool awaitCommands = true}) async {
    appLanguages = await MultiLanguage(config.languagePath).init();
    // Waiting to load database after a few secounds in live or staging
    if (!config.isLocalDebug) {
      await Future.delayed(Duration(seconds: 30));
    }

    _db = await connectMongoDb().onError((_, __) {
      throw ("Error connect to MongoDB");
    });

    await connectMysqlDb();

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
    if (awaitCommands) {
      await handleCommands(server!);
    }
    return server!;
  }

  /// Handles incoming HTTP requests by processing them through routing functions and the [onRequest] function.
  ///
  /// If [config.dbConfig.enable] is true, this method ensures the MongoDB database is connected before handling requests.
  ///
  /// The request is processed in a guarded zone to catch and log errors, and an error response is sent if needed.
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

  /// Handles commands for the server, such as starting or stopping the server.
  Future<void> handleCommands(HttpServer server) async {
    if (this._args.isNotEmpty) {
      Console.p("Server started with arguments: ${this._args.join(', ')}");
    }
    await _runCommands(this._args);
    final input = stdin.transform(utf8.decoder);
    await for (String line in input.transform(LineSplitter())) {
      line = line.trim();
      line = line.replaceAll(RegExp('  '), ' ');
      if (line.isNotEmpty) {
        await _runCommands(line.split(' '));
      }
    }
  }

  Future<void> _runCommands(List<String> args) async {
    if (args.isEmpty) {
      return;
    }

    final cmdManager = CappManager(
      args: args,
      main: CappController(
        '',
        options: [
          CappOption(
            name: 'help',
            shortName: 'h',
            description: 'Show help',
          ),
        ],
        run: (c) async {
          return CappConsole(c.manager.getHelp(), CappColors.warning);
        },
      ),
      controllers: [
        CappController(
          'migrate',
          options: [
            CappOption(
              name: 'init',
              shortName: 'i',
              description: 'Init migration',
            ),
            CappOption(
              name: 'create',
              shortName: 'c',
              description: 'Create migration',
            ),
            CappOption(
              name: 'rollback',
              shortName: 'r',
              description: 'Rollback migration',
            ),
          ],
          description: 'Migration commands',
          run: (c) async {
            if (c.existsOption('init')) {
              var res = await CappConsole.progress<String>(
                "Initializing migration...",
                () async => MysqlMigration(mysqlDb).migrateInit(),
              );
              return CappConsole(res);
            }

            if (c.existsOption('create')) {
              var res = await CappConsole.progress<String>(
                "Creating migration...",
                () async => MysqlMigration(mysqlDb).migrateCreate(),
              );
              return CappConsole(res);
            }

            if (c.existsOption('rollback')) {
              int deep = c.getOption('rollback', def: '1').toInt(def: 1);
              var res = await CappConsole.progress<String>(
                "Rolling back migration...",
                () async => MysqlMigration(mysqlDb).migrateRollback(deep),
              );
              return CappConsole(res);
            }

            return CappConsole(
              "Please run the migration commands",
              CappColors.warning,
            );
          },
        ),
      ],
    );

    cmdManager.process();
  }

  /// Connects to MongoDB using the connection string from the configuration.
  ///
  /// If [config.dbConfig.enable] is true, the database connection is opened.
  ///
  /// Returns a [Future] containing the [mongo.Db] instance.
  Future<mongo.Db> connectMongoDb() async {
    var db = mongo.Db(config.dbConfig.link);
    if (config.dbConfig.enable) {
      await db.open().onError((err, stack) {
        Console.e(err.toString());
      });
    }
    return db;
  }

  /// Connects to MySQL using the connection string from the configuration.
  Future<void> connectMysqlDb() async {
    if (config.mysqlConfig.enable) {
      _mysqlDb = await MySQLConnection.createConnection(
        host: config.mysqlConfig.host,
        port: config.mysqlConfig.port,
        userName: config.mysqlConfig.user,
        password: config.mysqlConfig.pass,
        databaseName: config.mysqlConfig.databaseName,
        secure: config.mysqlConfig.secure,
        collation: config.mysqlConfig.collation,
      );
      _mysqlDb!.onClose(
        () => Console.e("MySQL connection closed"),
      );
      if (config.mysqlConfig.enable) {
        await _mysqlDb!.connect().onError((err, stack) {
          Console.e(err.toString());
        });
      }
    }
  }

  /// Registers a [WaCron] instance to be scheduled.
  ///
  /// The [cron] parameter is the [WaCron] instance to be registered.
  void registerCron(WaCron cron) {
    crons.add(cron);
  }
}

/// A class that holds version information for the server.
class _Info {
  /// The version of the server.
  final String version = '2.0.0';
}
