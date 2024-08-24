import 'dart:async';
import '../controllers/dw_auth_controller.dart';
import '../router/api_doc.dart';
import '../render/web_request.dart';
import 'request_methods.dart';
import 'dw_controller.dart';

class WebRoute {
  /// Your main path of your roater, you can use /test, /test/*
  /// if you use [test/*] then you will have all sub paths
  late String path;

  /// More main paths of this router
  late List<String> extraPath;

  /// POST/GET/HEAD/DELETE and other
  late List<String> methods;

  /// The controller that you attached in this router
  late DwController? controller;

  /// Main functions of controller that you want load for this
  late Future<String> Function()? index;

  /// Fore safety you can add [DwAuthController] for check sessions.
  late DwAuthController? auth;

  /// the permissions that can use for auth, pay atention that the Authentication needs for this option
  late List<String> permissions = [];

  /// [WebRequest] is main context of pages or routers
  late WebRequest rq;

  /// the path of widgets that you want load as content
  late String widget;

  /// the default variable params that will using on content
  late Map<String, Object?> params;

  /// title of page that you can use as an <?= $e.pageTitle ?>
  late String title;

  /// the paths that you dont like be in all subpath of /*
  late List<String> excludePaths;

  /// the sub routers of current router that you can define them as tree
  List<WebRoute> children;

  /// ApiDoc
  Future<ApiDoc>? Function()? apiDoc;

  String _pathAfterRender = '';
  void setPathRender(String path) => _pathAfterRender = path;
  String getPathRender() => _pathAfterRender;

  WebRoute({
    required this.path,
    required this.rq,
    this.extraPath = const [],
    this.methods = const [RequestMethods.GET],
    this.controller,
    this.widget = "",
    this.index,
    this.auth,
    this.children = const [],
    this.params = const {},
    this.title = '',
    this.excludePaths = const [],
    this.apiDoc,
    this.permissions = const [],
  }) : super();

  bool allowMethod() {
    return (methods.contains(rq.method));
  }

  List<Map> toMap(String parentPath, bool hasAuth, String method) {
    var res = <Map>[];

    res.add({
      'path': path,
      'fullPath': "$parentPath$path",
      'hasAuth': hasAuth || auth != null,
      'method': method,
      'value': "[$method]$parentPath$path",
      'type': "$parentPath$path".startsWith('/api/') ? 'API' : 'WEB',
      'permissions': permissions,
      'controller': controller?.toString(short: true),
      'index':
          index?.toString().split(' ').last.replaceAll(RegExp(r"[:'.]"), ''),
    });

    for (var epath in extraPath) {
      res.add({
        'path': epath,
        'fullPath': "$parentPath$epath",
        'hasAuth': hasAuth || auth != null,
        'method': method,
        'value': "[$method]$parentPath$epath",
        'type': "$parentPath$path".startsWith('/api/') ? 'API' : 'WEB',
        'permissions': permissions,
        'controller': controller?.toString(short: true),
        'index':
            index?.toString().split(' ').last.replaceAll(RegExp(r"[:'.]"), ''),
      });
    }

    return res;
  }

  static List<WebRoute> makeList({
    required List<String> paths,
    required WebRequest rq,
    List<String> extraPath = const [],
    List<String> methods = const [RequestMethods.GET],
    DwController? controller,
    Future<String> Function()? index,
    DwAuthController? auth,
    List<String> permissions = const [],
    String widget = "",
    Map<String, Object?> params = const {},
    String title = "",
    List<String> excludePaths = const [],
    List<WebRoute> children = const [],
    Future<ApiDoc>? Function()? apiDoc,
  }) {
    var res = <WebRoute>[];

    for (var path in paths) {
      res.add(WebRoute(
        path: path,
        rq: rq,
        index: index,
        apiDoc: apiDoc,
        auth: auth,
        children: children,
        controller: controller,
        excludePaths: excludePaths,
        extraPath: extraPath,
        methods: methods,
        params: params,
        permissions: permissions,
        title: title,
        widget: widget,
      ));
    }

    return res;
  }
}
