import 'dart:io';
import 'package:path/path.dart' as p;

extension WaFile on File {
  String get fileName {
    return p.basenameWithoutExtension(path);
  }

  String get fileExtension {
    return p.extension(path);
  }

  String get filePath {
    return p.dirname(path);
  }

  String get fileFullName {
    return p.basename(path);
  }
}
