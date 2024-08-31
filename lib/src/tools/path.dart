import 'dart:io';

import 'package:path/path.dart' as p;

/// Normalizes and joins a given [path] with the application base directory path.
///
/// This function normalizes the input [path], formats it as a URI, applies
/// additional path normalization, and finally joins it with the application
/// directory path obtained from [pathApp].
///
/// Example usage:
/// ```dart
/// String fullPath = pathTo('assets/images');
/// ```
String pathTo(String path) {
  path = p.normalize(path);
  path = p.prettyUri(path);
  path = pathNorm(path);
  return p.normalize(p.join(pathApp, path));
}

/// Joins a list of paths into a single normalized path string.
///
/// The first element in [paths] is joined as-is, while subsequent elements
/// are normalized using [pathNorm] to ensure consistency.
///
/// Example usage:
/// ```dart
/// String fullPath = joinPaths(['assets', 'images', 'logo.png']);
/// ```
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

/// Normalizes a given [path] by removing leading slashes and optionally converting
/// backslashes to forward slashes.
///
/// The [normSlashs] parameter, if set to `true`, replaces all backslashes (`\`)
/// with forward slashes (`/`) in the normalized path.
///
/// Example usage:
/// ```dart
/// String normalizedPath = pathNorm('C:\\User\\Documents\\file.txt', normSlashs: true);
/// ```
String pathNorm(String path, {bool? normSlashs, endWithSlash = false}) {
  path = p.normalize(path);
  if (path.startsWith('/') || path.startsWith("\\")) path = path.substring(1);
  if (normSlashs != null && normSlashs) {
    path = path.replaceAll('\\', '/');
  }

  if (endWithSlash && !path.endsWith('/')) {
    path += '/';
  }
  return path;
}

String endpointNorm(
  List<String> paths, {
  bool normSlashs = true,
  endWithSlash = true,
  startWithSlash = true,
}) {
  var path = joinPaths(paths);
  if (endWithSlash && !path.endsWith('/')) {
    path += '/';
  }

  if (startWithSlash && !path.startsWith('/')) {
    path = '/$path';
  }

  if (normSlashs) {
    path = path.replaceAll('\\', '/');
  }
  path = path.replaceAll('//', '/');
  return path;
}

/// Retrieves the base directory path of the application.
///
/// This getter uses the script path from [Platform.script] and navigates up two levels
/// to return the root application path.
///
/// Example usage:
/// ```dart
/// String appPath = pathApp;
/// ```
String get pathApp {
  var scriptPath = Platform.script.toFilePath();
  return Directory(scriptPath).parent.parent.path;
}
