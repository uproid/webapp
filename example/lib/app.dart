import '../core/local_events.dart';
import 'package:webapp/wa_route.dart';

import 'db/job_collection_free.dart';
import 'db/person_collection_free.dart';
import 'package:webapp/wa_model_less.dart';
import 'db/example_collections.dart';
import 'models/example_model.dart';
import 'package:webapp/wa_console.dart';
import 'package:webapp/wa_server.dart';
import 'package:webapp/wa_tools.dart';
import 'route/socket_route.dart';
import 'route/web_route.dart';

WaConfigs configs = WaConfigs(
  widgetsPath: pathTo(env['WIDGETS_PATH'] ?? "./lib/widgets"),
  widgetsType: env['WIDGETS_TYPE'] ?? 'j2.html',
  languagePath: pathTo(env['LANGUAGE_PATH'] ?? "./lib/languages"),
  publicDir: pathTo(env['PUBLIC_DIR'] ?? './public'),
  dbConfig: WaDBConfig(
    enable: true, //env['ENABLE_DATABASE'] == 'true',
    dbName: 'example',
    auth: 'admin',
    pass: 'PasswordMongoDB',
    host: env['MONGO_CONNECTION'] ?? 'localhost',
    port: env['MONGO_PORT'] ?? '27018',
    user: 'root',
  ),
  port: (env['DOMAIN_PORT'] ?? '8085').toInt(def: 8085),
  mysqlConfig: WaMysqlConfig(
    enable: true,
    host: env['MYSQL_HOST'] ?? 'localhost',
    port: 3306,
    user: 'example_user',
    pass: 'example_password',
    databaseName: 'example_db',
  ),
  blockStart: "{%",
  blockEnd: "%}",
  variableStart: "{{",
  variableEnd: "}}",
  commentStart: "{#",
  commentEnd: "#}",
);

final server = WaServer(configs: configs);
var jobCollectionFree = JobCollectionFree(db: server.db);
var personCollectionFree = PersonCollectionFree(db: server.db);

final socketManager = SocketManager(
  server,
  event: SocketEvent(
    onConnect: (socket) {
      server.socketManager?.sendToAll(
        "New user connected! count: ${server.socketManager?.countClients}",
        path: "output",
      );
      socket.send(
        {'message': 'Soccuess connect to socket!'},
        path: 'connected',
      );
    },
    onMessage: (socket, data) {},
    onDisconnect: (socket) {
      var count = server.socketManager?.countClients ?? 0;
      server.socketManager?.sendToAll(
        "User disconnected! count: ${count - 1}",
        path: "output",
      );
    },
  ),
  routes: getSocketRoute(),
);

void main([List<String>? args]) async {
  server.addRouting(getWebRoute);
  WebRequest.localEvents.addAll(localEvents);
  WebRequest.addLocalLayoutFilters(localLayoutFilters);
  server.start(args).then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
  });

  /// Example Cron job
  server.registerCron(
    /// Evry 2 days clean the example collection of database
    WaCron(
      schedule: WaCron.evryDay(2),
      onCron: (index, cron) async {
        if (server.db.isConnected) {
          ExampleCollections().deleteAll();
        }
      },
      delayFirstMoment: true,
    ).start(),
  );

  server.registerCron(
    /// Add evry hour a new document to the example collection of database
    WaCron(
      schedule: "0 * * * *",
      onCron: (index, cron) async {
        if (server.db.isConnected) {
          ExampleCollections().insertExample(ExampleModel(
            title: DateTime.now().toString(),
            slug: 'slug-$index',
          ));
        }
      },
      delayFirstMoment: true,
    ).start(),
  );
}

printDB() {
  DBCollectionFree.printDesign();
}
