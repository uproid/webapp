import 'dart:io';

import 'package:webapp/src/tools/path.dart';
import 'package:webapp/wa_cli.dart';

class ProjectCommands {
  Future<CmdConsole> get(CmdController controller) async {
    await Process.start(
      'dart',
      ['pub', 'get'],
      mode: ProcessStartMode.inheritStdio,
    );
    return CmdConsole("dart pub get", Colors.info);
  }

  Future<CmdConsole> runner(CmdController controller) async {
    await Process.start(
      'dart',
      ['run', 'build_runner', 'build'],
      mode: ProcessStartMode.inheritStdio,
    );
    return CmdConsole('dart run build_runner build', Colors.none);
  }

  Future<CmdConsole> run(CmdController controller) async {
    var path = controller.getOption('path');
    var defaultPath = [
      './bin',
      './lib',
      './src',
    ];

    var defaultApp = [
      'app.dart',
      'dart.dart',
      'example.dart',
      'run.dart',
      'watcher.dart',
    ];

    if (path.isEmpty) {
      for (var p in defaultPath) {
        for (var a in defaultApp) {
          var file = File(joinPaths([p, a]));
          if (file.existsSync()) {
            path = file.path;
            break;
          }
        }
      }
    }
    if (path.isEmpty) {
      path = CmdConsole.read(
        "Enter path of app file:",
        isRequired: true,
      );
      if (!File(path).existsSync()) {
        return run(controller);
      }
    } else {
      print("Running project from: $path");
    }
    await Process.start(
      'dart',
      [
        'run',
        "--enable-asserts",
        path,
      ],
      mode: ProcessStartMode.inheritStdio,
    );
    return CmdConsole("Start running project...", Colors.info);
  }
}
