import 'package:webapp/wa_server.dart';

import '../app.dart';

Map<String, SocketEvent> getSocketRoute() {
  var count = 0;
  return {
    'test': SocketEvent(
      onMessage: (socket, data) {
        socket.send([socket.rq.headers], path: 'test');
      },
    ),
    'close': SocketEvent(
      onMessage: (socket, data) {
        socket.close();
      },
    ),
    'time': SocketEvent(
      onMessage: (socket, data) {
        socket.send(DateTime.now().toString(), path: 'output');
      },
    ),
    'fa': SocketEvent(
      onMessage: (socket, data) async {
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration(seconds: 1), () {
            count++;
            socket.send('======= $count ====== ', path: 'output');
          });
        }
      },
    ),
    'clients': SocketEvent(
      onMessage: (socket, data) {
        var clients = server.socketManager?.getAllClientsKeys();
        socket.send(clients, path: 'clients');
      },
    ),
    'toclient': SocketEvent(
      onMessage: (socket, data) {
        var id = data['data']?['id'] ?? '';
        var message = data['data']?['message'] ??
            'You receive new message form other client';
        var client = socket.manager.session.getClient(id);
        client?.send(
          "Client ${socket.id}: $message",
          path: 'output',
        );
      },
    ),
  };
}
