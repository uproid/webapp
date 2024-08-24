import 'dart:io';

import 'package:path/path.dart' as p;

String pathTo(String path) {
  path = p.normalize(path);
  path = p.prettyUri(path);
  path = pathNorm(path);
  return p.normalize(p.join(pathApp, path));
}

String joinPaths(List<String> paths) {
  var pathsNorm = <String>[];
  var isNotFirst = false;
  for (var element in paths) {
    if (isNotFirst) {
      element = pathNorm(element);
    } else {
      isNotFirst = true;
    }
    pathsNorm.add(element);
  }
  return p.joinAll(pathsNorm);
}

String pathNorm(String path, {bool? normSlashs}) {
  path = p.normalize(path);
  if (path.startsWith('/') || path.startsWith("\\")) path = path.substring(1);
  if (normSlashs != null && normSlashs) {
    path = path.replaceAll('\\', '/');
  }
  return path;
}

String get pathApp {
  var scriptPath = Platform.script.toFilePath();
  return Directory(scriptPath).parent.parent.path;
}
