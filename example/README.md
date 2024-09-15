### Run

```shel
docker compose up --build
```

## Examples
  Please refer to the documentation and the GitHub page for a comprehensive review of the examples. You can also view the example as a [Demo](https://webapp.uproid.com).

### [View Examples](https://github.com/uproid/webapp/tree/master/example)  |  [Live Demo](https://webapp.uproid.com) | [Documentations](https://github.com/uproid/webapp/tree/master/docs)

```dart
import 'package:webapp/wa_console.dart';
import 'package:webapp/wa_server.dart';
import 'package:webapp/wa_tools.dart';
import 'lib/route/socket_route.dart';
import 'lib/route/web_route.dart';

WaConfigs configs = WaConfigs(
  widgetsPath: pathTo(env['WIDGETS_PATH'] ?? "./example/widgets"),
  widgetsType: env['WIDGETS_TYPE'] ?? 'j2.html',
  languagePath: pathTo(env['LANGUAGE_PATH'] ?? "./example/languages"),
  publicDir: pathTo(env['PUBLIC_DIR'] ?? './example/public'),
  dbConfig: WaDBConfig(enable: false),
  port: 8085,
);

WaServer server = WaServer(configs: configs);

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

void main() async {
  server.addRouting(getWebRoute);
  server.start().then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
  });
}

```