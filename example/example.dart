import 'package:dweb/dw_console.dart';
import 'package:dweb/dw_server.dart';
import 'package:dweb/dw_tools.dart';
import 'route/socket_route.dart';
import 'route/web_route.dart';

DwConfigs configs = DwConfigs(
  widgetsPath: pathTo("./example/widgets"),
  widgetsType: 'j2.html',
  languagePath: pathTo('./example/languages'),
  port: 8085,
  dbConfig: DwDBConfig(enable: false),
  publicDir: pathTo('./example/public'),
);
DwServer server = DwServer(configs: configs);

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
