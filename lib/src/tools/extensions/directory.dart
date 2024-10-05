import 'dart:io';
import 'package:path/path.dart' as p;

extension WaDirectory on Directory {
  Future<void> copyDirectory(Directory to) async {
    if (!to.existsSync()) {
      to.createSync(recursive: true);
    }

    for (var entity in this.listSync(recursive: true)) {
      if (entity is Directory) {
      } else if (entity is File) {
        var filePath = p.join(
          to.path,
          p.relative(entity.path, from: this.path),
        );
        var file = File(filePath);
        if (!file.parent.existsSync()) {
          file.parent.createSync(recursive: true);
        }
        entity.copySync(file.path);
      }
    }
  }

  Future<void> cleanDirectory() async {
    this.deleteSync(recursive: true);
    this.createSync(recursive: true);
  }
}
