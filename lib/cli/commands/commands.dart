import 'dart:io';

import 'package:webapp/src/tools/path.dart';
import 'package:webapp/wa_cli.dart';
import 'package:webapp/wa_server.dart';

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
    var proccess = await Process.start(
      'dart',
      [
        'run',
        "--enable-asserts",
        path,
      ],
      mode: ProcessStartMode.inheritStdio,
    );

    var help = "Project is running (${proccess.pid})...\n\n" +
        "┌┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬──────────┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐\n" +
        "││││││││││││││││││││││  WEBAPP  │││││││││││││││││││││\n" +
        "├┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴──────────┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┤\n" +
        "│  * Press 'r' to Reload  the project               │\n" +
        "├───────────────────────────────────────────────────┤\n" +
        "│  * Press 'c' to clear screen                      │\n" +
        "├───────────────────────────────────────────────────┤\n" +
        "│  * Press 'i' to write info                        │\n" +
        "├───────────────────────────────────────────────────┤\n" +
        "│  * Press 'q' to quit the project                  │\n" +
        "└───────────────────────────────────────────────────┘\n";

    // Listen for user input in a separate loop
    stdin.listen((input) async {
      String userInput = String.fromCharCodes(input).trim();

      if (userInput.toLowerCase() == 'r') {
        CmdConsole.clear();
        CmdConsole.write("Restart project...", Colors.warnnig);
        proccess.kill();
        proccess = await Process.start(
          'dart',
          [
            'run',
            "--enable-asserts",
            path,
          ],
          mode: ProcessStartMode.inheritStdio,
        );
      } else if (['q', 'qy', 'qq'].contains(userInput.toLowerCase())) {
        var res = true;
        if (userInput.toLowerCase() == 'q') {
          res = CmdConsole.yesNo("Do you want to quit the project?");
        }
        if (res) {
          proccess.kill();
          exit(0);
        }
      } else if (userInput.toLowerCase() == 'c') {
        CmdConsole.clear();
      } else if (userInput.toLowerCase() == 'i') {
        CmdConsole.write("WebApp version: v${WaServer.info.version}");
        CmdConsole.write("Dart version: v${Platform.version}");
      } else {
        CmdConsole.write(
          "Unknown input: ${userInput.toLowerCase()}",
          Colors.error,
        );
        CmdConsole.write(help, Colors.success);
      }
    });

    return CmdConsole(help, Colors.success);
  }
}
