import 'dart:io';
import '../dw_server.dart';
import '../controllers/dw_auth_controller.dart';
import '../router/web_route.dart';
import 'package:mime/mime.dart';
import '../tools/path.dart';
import '../render/web_request.dart';

class Route {
  List<WebRoute> routing = [];
  DwAuthController? seenAuth;
  WebRequest rq;

  Route({required this.routing, required this.rq});

  void handel() async {
    checkAll(routing);
  }

  Future<bool> checkAll(
    List<WebRoute> routing, {
    String parentPath = '',
  }) async {
    for (var i = 0; i < routing.length; i++) {
      var route = routing[i];
      List<String> paths = [route.path, ...route.extraPath];
      for (var path in paths) {
        path = "$parentPath$path";
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

  Future<({bool found, Map<String, Object?> urlParams})> checkOne(
    WebRoute route,
    final String key,
  ) async {
    var urlParams = <String, Object?>{};
    final pathClient = route.rq.uri.path;
    var endpoint = key.endsWith('/') ? key : "$key/";
    var path = pathClient.endsWith('/') ? pathClient : "$pathClient/";
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
        final special = starPath.endsWith('/') ? starPath : "$starPath/";

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

      if (await checkAll(route.children, parentPath: key)) {
        return (found: true, urlParams: urlParams);
      }
    }
    return (found: false, urlParams: urlParams);
  }

  Future<bool> checkPermission(DwAuthController? auth) async {
    if (auth == null) {
      return true;
    }
    var res = await auth.checkPermission();

    if (!res) {
      rq.renderError(403, message: 'Access denied!', toData: rq.isApiEndpoint);
    }
    return res;
  }

  File getFileFromPublic(String path) {
    String longPath = getPublicDirectory(path);
    return File(longPath);
  }

  void renderFile(File file) {
    var fileStream = file.openRead();

    rq.response.headers
        .set('Content-type', lookupMimeType(file.path).toString());
    rq.response.addStream(fileStream).then((value) async {
      await rq.writeAndClose('');
    });
  }

  String getPublicDirectory(String? filePath) {
    return pathTo("${DwServer.config.publicDir}/$filePath");
  }

  void renderWidget(String uri) {
    rq.renderView(
      path: uri,
    );
  }

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
