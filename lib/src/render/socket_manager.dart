import 'dart:convert';
import 'dart:io';
import 'package:webapp/wa_server.dart';
import 'package:webapp/src/render/web_request.dart';
import 'package:webapp/src/tools/convertor/serializable/value_converter.dart/json_value.dart';

class SocketManager {
  WaServer server;
  SocketEvent? event;
  Map<String, SocketEvent> routes = {};

  SocketManager(
    this.server, {
    this.event,
    this.routes = const {},
  }) {
    server.socketManager = this;
  }

  final SessionsManager session = SessionsManager();
  int get countClients => session.countClients;
  int get countUsers => session.countUsers;

  void addEvents(Map<String, SocketEvent> events) {
    routes.addAll(events);
  }

  Future<WebRequest> requestHandel(WebRequest rq, {String? userId}) async {
    var socket = await WebSocketTransformer.upgrade(rq.httpRequest);
    final id = rq.headers['sec-websocket-key']!.first;
    session.add(
      id,
      SocketClient(
        id: id,
        socket: socket,
        rq: rq,
        manager: this,
      ),
      userID: userId,
    );

    if (session.getClient(id) != null) {
      event?.onConnect?.call(session.getClient(id)!);
    }

    socket.listen(
      (data) {
        var res = <String, dynamic>{};
        try {
          res = WaJson.jsonDecoder(data);
        } catch (e) {
          res = {'path': 'error', 'data': data};
        }

        if (routes.containsKey(res['path'] ?? '')) {
          routes[res['path']]?.onMessage!(session.getClient(id)!, res);
        } else if (event?.onMessage != null) {
          event?.onMessage!(session.getClient(id)!, res);
        }
      },
      onDone: () async {
        await event?.onDisconnect?.call(session.getClient(id)!);
        session.remove(id);
      },
      onError: (data) async {
        var res = <String, dynamic>{};
        try {
          res = jsonDecode(data);
        } catch (e) {
          res = {'path': 'error', 'data': data};
        }
        event?.onMessage!(session.getClient(id)!, res);
        event?.onError?.call(session.getClient(id)!, res);
        await event?.onDisconnect?.call(session.getClient(id)!);
        session.remove(id);
      },
      cancelOnError: true,
    );

    return rq;
  }

  Future close() async {
    for (var client in session.getAllClients().values) {
      client.socket.close();
    }

    session.clear();
  }

  List<String> getAllClientsKeys() {
    return session.getAllClients().keys.toList();
  }

  Future sendToAll(dynamic data, {int status = 200, String? path}) async {
    for (var client in session.getAllClients().values) {
      client.send(data, status: status, path: path);
    }
  }

  Future sendToClinet(
    String id,
    dynamic data, {
    int status = 200,
    String? path,
  }) async {
    if (session.existClient(id)) {
      session.getClient(id)!.send(data, status: status, path: path);
    }
  }

  Future sendToUser(
    String id,
    dynamic data, {
    int status = 200,
    String? path,
  }) async {
    session.getUserClientsSocket(id).forEach((clientSocket) {
      clientSocket.send(data, status: status, path: path);
    });
  }
}

class SocketEvent {
  Function(SocketClient socket)? onConnect;
  Function(SocketClient socket)? onDisconnect;
  Function(SocketClient socket, Map<String, dynamic> data)? onError;
  Function(SocketClient socket, Map<String, dynamic> data)? onMessage;
  SocketEvent({
    this.onConnect,
    this.onDisconnect,
    this.onError,
    this.onMessage,
  });
}

class SocketClient {
  SocketManager manager;
  String id;
  WebSocket socket;
  WebRequest rq;

  SocketClient({
    required this.id,
    required this.socket,
    required this.rq,
    required this.manager,
  });

  Future send(dynamic data, {int status = 200, String? path}) async {
    var res = <String, dynamic>{};
    res['path'] = path ?? '';
    res['status'] = status;
    res['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    res['language'] = rq.getLanguage();
    res['client'] = id;
    res['data'] = data;
    socket.add(WaJson.jsonEncoder(res));
  }

  Future close() async {
    socket.close();
    manager.session.remove(id);
  }
}

class SessionsManager {
  final Map<String, SocketClient> _clients = {};
  final Map<String, List<String>> _users = {};

  bool existClient(String id) {
    return _clients.containsKey(id);
  }

  bool existUser(String userId) {
    return _users.containsKey(userId);
  }

  void add(String clinetID, SocketClient socket, {String? userID}) {
    _clients[clinetID] = socket;
    if (userID != null) {
      if (!_users.containsKey(userID)) {
        _users[userID] = [];
      }
      if (!_users[userID]!.contains(clinetID)) {
        _users[userID]!.add(clinetID);
      }
    }
  }

  List<String> getUserClientsID(String userID) {
    return _users[userID] ?? [];
  }

  List<SocketClient> getUserClientsSocket(String userID) {
    var allID = _users[userID] ?? [];
    var res = <SocketClient>[];
    for (var id in allID) {
      if (_clients.containsKey(id)) {
        res.add(_clients[id]!);
      }
    }

    return res;
  }

  SocketClient? getClient(String id) {
    return _clients[id];
  }

  Map<String, SocketClient> getAllClients() {
    return _clients;
  }

  void remove(String id) {
    _clients.remove(id);
    _users.removeWhere((userId, userClinets) {
      userClinets.remove(id);
      return userClinets.isEmpty;
    });
  }

  void clear() {
    _clients.clear();
    _users.clear();
  }

  int get countUsers => _users.length;
  int get countClients {
    return _clients.length;
  }

  int getCountUserClients(String userID) {
    return _users[userID]?.length ?? 0;
  }
}
