import 'dart:io';
import 'package:path/path.dart' as p;

extension WaFile on File {
  String get fileName {
    return p.basenameWithoutExtension(this.path);
  }

  String get fileExtension {
    return p.extension(this.path);
  }

  String get filePath {
    return p.dirname(this.path);
  }

  String get fileFullName {
    return p.basename(this.path);
  }
}
