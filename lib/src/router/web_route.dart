import 'dart:async';
import 'package:webapp/wa_tools.dart';

import '../controllers/wa_auth_controller.dart';
import '../router/api_doc.dart';
import '../render/web_request.dart';
import 'request_methods.dart';
import 'wa_controller.dart';

/// Represents a route in the web application, including path configurations, methods,
/// controllers, and authorization details.
///
/// The [WebRoute] class is used to define routes for handling HTTP requests. It allows
/// you to specify the main path, additional paths, HTTP methods, associated controllers,
/// and other details needed for routing and authorization.
class WebRoute {
  /// The primary path of the route. For example, `/test` or `/test/*`.
  /// If using `/test/*`, it will match all sub-paths under `/test`.
  late String path;

  /// The primary hostname of the route. for example `example.com`.
  /// by default is it `['*']` to match all hostnames.
  /// If using `example.com`, it will match only the `example.com` hostname.
  /// otherwise, it will match all hostnames that are set.
  late List<String> hosts;

  /// The primary port of the route. for example `[8080]`.
  /// by default is it `[]` to match all ports.
  /// If using `[8080]`, it will match only the `8080` port.
  /// otherwise, it will match all ports that are set.
  /// and then other ports will be ignored.
  late List<int> ports;

  /// Additional main paths for this route. This allows for multiple matching paths.
  late List<String> extraPath;

  /// List of HTTP methods allowed for this route. For example, `POST`, `GET`, `HEAD`, etc.
  late List<String> methods;

  /// The controller associated with this route. This is an instance of [WaController]
  /// that will handle the request for this route.
  late WaController? controller;

  /// A function representing the main controller function to load for this route.
  /// This is typically used to render the index of the controller.
  late Future<String> Function()? index;

  /// An optional [WaAuthController] for handling authentication and session checks
  /// for this route.
  late WaAuthController? auth;

  /// Permissions required for this route. Authentication is needed to use these permissions.
  late List<String> permissions = [];

  /// The [WebRequest] context for the current request.
  late WebRequest rq;

  /// Path to the widget to be loaded as content for this route.
  late String widget;

  /// Default variable parameters to use in the content.
  late Map<String, Object?> params;

  /// The title of the page, which can be used as `<?= $e.pageTitle ?>`.
  late String title;

  /// Paths that should not be included in all sub-paths of `/*`.
  late List<String> excludePaths;

  /// Sub-routes of the current route, defining a tree structure of routes.
  List<WebRoute> children;

  /// Function to generate API documentation for this route.
  Future<ApiDoc>? Function()? apiDoc;

  /// The path after rendering, used internally for path rendering.
  String _pathAfterRender = '';

  /// Sets the rendered path for this route.
  ///
  /// [path] is the full path after rendering.
  void setPathRender(String path) => _pathAfterRender = path;

  /// Gets the path after rendering.
  ///
  /// Returns the full path after rendering.
  String getPathRender() => _pathAfterRender;

  /// Creates a [WebRoute] instance with the specified parameters.
  ///
  /// [path] and [rq] are required parameters. All other parameters have default values.
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
    this.hosts = const ['*'],
    this.ports = const [],
  }) : super();

  /// Checks if the current HTTP method is allowed for this route.
  ///
  /// Returns `true` if the method is in the list of allowed methods, otherwise `false`.
  bool allowMethod() {
    return (methods.contains(rq.method));
  }

  /// Converts the route to a list of maps representing its details.
  ///
  /// [parentPath] is the base path for the route.
  /// [hasAuth] indicates whether the route requires authentication.
  /// [method] is the HTTP method being used.
  ///
  /// Returns a list of maps containing details about the route.
  List<Map> toMap(String parentPath, bool hasAuth, String method) {
    var res = <Map>[];
    final endpoint = endpointNorm([parentPath, path]);
    res.add({
      'path': path,
      'fullPath': endpoint,
      'hasAuth': hasAuth || auth != null,
      'method': method,
      'value': "[$method]$endpoint",
      'type': endpoint.startsWith('/api/') ? 'API' : 'WEB',
      'permissions': permissions,
      'controller': controller?.toString(short: true),
      'index':
          index?.toString().split(' ').last.replaceAll(RegExp(r"[:'.]"), ''),
      'hosts': hosts,
      'ports': ports,
    });

    for (var epath in extraPath) {
      var eEndpoint = endpointNorm([parentPath, epath]);
      res.add({
        'path': epath,
        'fullPath': eEndpoint,
        'hasAuth': hasAuth || auth != null,
        'method': method,
        'value': "[$method]$eEndpoint",
        'type': eEndpoint.startsWith('/api/') ? 'API' : 'WEB',
        'permissions': permissions,
        'controller': controller?.toString(short: true),
        'index':
            index?.toString().split(' ').last.replaceAll(RegExp(r"[:'.]"), ''),
        'hosts': hosts,
        'ports': ports,
      });
    }

    return res;
  }

  /// Creates a list of [WebRoute] instances from the given parameters.
  ///
  /// [paths] is a list of main paths for the routes.
  /// [rq] is the [WebRequest] context for the routes.
  /// All other parameters have default values.
  ///
  /// Returns a list of [WebRoute] instances.
  static List<WebRoute> makeList({
    required List<String> paths,
    required WebRequest rq,
    List<String> extraPath = const [],
    List<String> methods = const [RequestMethods.GET],
    WaController? controller,
    Future<String> Function()? index,
    WaAuthController? auth,
    List<String> permissions = const [],
    String widget = "",
    Map<String, Object?> params = const {},
    String title = "",
    List<String> excludePaths = const [],
    List<WebRoute> children = const [],
    Future<ApiDoc>? Function()? apiDoc,
    List<String> hosts = const ['*'],
    List<int> ports = const [],
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
        hosts: hosts,
        ports: ports,
      ));
    }

    return res;
  }
}
