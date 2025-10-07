import 'dart:io';
import 'package:webapp/wa_route.dart';
import '../wa_server.dart';
import 'package:mime/mime.dart';
import '../tools/path.dart';

/// A class that handles route management and request processing for a web application.
///
/// This class processes incoming requests, matches them to defined routes, and handles
/// rendering of files or widgets based on the route configuration. It also performs
/// authentication checks and permission validations as required by the routes.
class Route {
  /// A list of [WebRoute] objects defining the routing paths and configurations.
  List<WebRoute> routing = [];

  /// An optional [WaAuthController] instance used for managing authentication.
  WaAuthController? seenAuth;

  /// The [WebRequest] object representing the current web request.
  WebRequest get rq => RequestContext.rq;

  /// Creates a [Route] instance.
  ///
  /// The [routing] parameter is required to initialize the list of routes, and the [rq]
  /// parameter is required for the current web request.
  Route({required this.routing});

  /// Handles the routing logic by checking all defined routes.
  ///
  /// This method initiates the route checking process by calling [checkAll] with the
  /// defined routes.
  void handel() async {
    checkAll(routing);
  }

  /// Checks all routes to determine if a request matches any defined route.
  ///
  /// The [routing] parameter is a list of [WebRoute] objects to check. The [parentPath]
  /// parameter is used for constructing nested routes.
  ///
  /// Returns a [Future<bool>] indicating whether a matching route was found. If no match
  /// is found, it attempts to serve static files from the public directory or returns a 404
  /// error if the file is not found. If an error occurs during file access, a 502 error is returned.
  Future<bool> checkAll(
    List<WebRoute> routing, {
    String parentPath = '',
  }) async {
    for (var i = 0; i < routing.length; i++) {
      var route = routing[i];
      route.rq = rq;
      if (route.hosts.isNotEmpty && !route.hosts.contains('*')) {
        if (!route.hosts.contains(rq.host)) {
          continue;
        }
      }

      if (route.ports.isNotEmpty) {
        if (!route.ports.contains(rq.port)) {
          continue;
        }
      }

      List<String> paths = [route.path, ...route.extraPath];
      for (var path in paths) {
        path = joinPaths([parentPath, path]);
        route.setPathRender(path);
        rq.route = route;
        var res = await checkOne(route, path);
        if (res.found) {
          return true;
        }
      }
    }

    if (parentPath.isNotEmpty) return false;

    /// this lines works when nginx is not in local
    /// then it helps to load other files from public
    /// try to use nginx in production for better performance
    /// and security
    var publicFile = getFileFromPublic(rq.uri.path);
    try {
      if (publicFile.existsSync()) {
        renderFile(publicFile);
        return true;
      }
      rq.renderError(404, toData: rq.isApiEndpoint);
    } catch (e) {
      rq.renderError(502, toData: rq.isApiEndpoint);
    }

    return false;
  }

  /// Checks a single route to see if it matches the given key.
  ///
  /// The [route] parameter is the [WebRoute] object to check, and the [key] parameter is
  /// the route path to match.
  ///
  /// Returns a [Future] with a tuple containing:
  /// - `found`: A boolean indicating whether a matching route was found.
  /// - `urlParams`: A map of URL parameters extracted from the route.
  Future<({bool found, Map<String, Object?> urlParams})> checkOne(
    WebRoute route,
    final String key,
  ) async {
    route.rq = rq;
    var urlParams = <String, Object?>{};
    final pathClient = route.rq.uri.path;
    var endpoint = endpointNorm([key]);
    var path = endpointNorm([pathClient]);
    rq.addParams(route.params);

    // Check is param or not
    if (key.contains("{")) {
      var paramPath = getParamsPath(path, endpoint);
      urlParams = paramPath.$2;
      endpoint = paramPath.$1;
    }

    if (endpoint.endsWith('*/')) {
      endpoint = endpoint.replaceAll('*/', '');

      var isTarget = true;
      final starPath = path.replaceFirst(endpoint, '');
      for (var excluded in route.excludePaths) {
        final special = endpointNorm([starPath]);
        excluded = endpointNorm([excluded]);

        if (special.startsWith(excluded)) {
          isTarget = false;
          break;
        }
      }

      if (isTarget && path.endsWith(starPath)) {
        path = path.replaceFirst(starPath, '');
      }
    }

    if (endpoint == path) {
      if (!route.allowMethod()) {
        return (found: false, urlParams: urlParams);
      }

      if (route.widget.isNotEmpty) {
        if (!await checkPermission(seenAuth)) {
          return (found: false, urlParams: urlParams);
        }
        rq.addParams(urlParams);
        renderWidget(route.widget);
        return (found: true, urlParams: urlParams);
      }

      if (route.auth != null) {
        seenAuth = route.auth;
        var res = await route.auth!.auth();
        if (res == false) return (found: false, urlParams: urlParams);
      }

      if (route.index == null) {
        if (route.controller != null) {
          if (!await checkPermission(seenAuth)) {
            return (found: false, urlParams: urlParams);
          }
          rq.addParams(urlParams);

          await route.controller!.index();
          return (found: true, urlParams: urlParams);
        } else {
          return (found: false, urlParams: urlParams);
        }
      } else {
        if (!await checkPermission(seenAuth)) {
          return (found: false, urlParams: urlParams);
        }
        route.rq = rq;
        rq.addParams(urlParams);
        await route.index!();
        return (found: true, urlParams: urlParams);
      }
    } else if (route.children.isNotEmpty && path.contains(endpoint)) {
      if (route.auth != null) {
        seenAuth = route.auth;
        var res = await route.auth!.auth();
        if (res == false) return (found: false, urlParams: urlParams);
      }
      route.rq = rq;
      if (await checkAll(route.children, parentPath: key)) {
        return (found: true, urlParams: urlParams);
      }
    }
    return (found: false, urlParams: urlParams);
  }

  /// Checks if the current request has the required permissions.
  ///
  /// The [auth] parameter is an optional [WaAuthController] used for permission checking.
  ///
  /// Returns a [Future<bool>] indicating whether the permission check was successful.
  Future<bool> checkPermission(WaAuthController? auth) async {
    if (auth == null) {
      return true;
    }
    var res = await auth.checkPermission();

    if (!res) {
      rq.renderError(403, message: 'Access denied!', toData: rq.isApiEndpoint);
    }
    return res;
  }

  /// Retrieves a file from the public directory based on the provided path.
  ///
  /// The [path] parameter specifies the file path relative to the public directory.
  ///
  /// Returns a [File] object representing the file.
  File getFileFromPublic(String path) {
    String longPath = getPublicDirectory(path);
    return File(longPath);
  }

  /// Renders a file by streaming its content to the response.
  ///
  /// The [file] parameter is the [File] object to render.
  void renderFile(File file) {
    var fileStream = file.openRead();

    rq.response.headers
        .set('Content-type', lookupMimeType(file.path).toString());
    rq.response.addStream(fileStream).then((value) async {
      await rq.writeAndClose('');
    });
  }

  /// Constructs the full path to a file in the public directory.
  ///
  /// The [filePath] parameter is the relative path to the file.
  ///
  /// Returns the absolute path as a [String].
  String getPublicDirectory(String? filePath) {
    return pathTo("${WaServer.config.publicDir}/$filePath");
  }

  void renderWidget(String uri) {
    rq.renderView(
      path: uri,
    );
  }

  /// Extracts parameters from the client path and server path.
  ///
  /// The [clientPath] parameter is the path from the client's request. The [serverPath]
  /// parameter is the path defined in the route.
  ///
  /// Returns a tuple where:
  /// - The first element is the processed server path.
  /// - The second element is a map of URL parameters extracted from the client path.
  (String, Map<String, Object?>) getParamsPath(
    String clientPath,
    String serverPath,
  ) {
    String resultKey = serverPath;
    Map<String, Object?> resultParams = {};

    var serverUri = Uri(path: serverPath);
    var clientUri = Uri(path: clientPath);

    if (serverUri.pathSegments.length != clientUri.pathSegments.length) {
      return (resultKey, resultParams);
    }

    for (int i = 0; i < clientUri.pathSegments.length; i++) {
      var key = Uri.decodeFull(serverUri.pathSegments[i]);
      if (!key.startsWith("{") || !key.endsWith("}")) {
        continue;
      } else {
        key = key.replaceAll("{", "").replaceAll("}", "");
        resultKey = resultKey.replaceFirst("{$key}", clientUri.pathSegments[i]);
        resultParams[key] = clientUri.pathSegments[i];
      }
    }

    return (resultKey, resultParams);
  }
}
