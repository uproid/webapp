import 'dart:io';

import 'package:webapp/src/cli/core/cmd_console.dart';
import 'package:webapp/src/cli/core/cmd_controller.dart';
import 'package:webapp/src/wa_server.dart';

class Main {
  Future<CmdConsole> main(CmdController controller) async {
    if (controller.existsOption('version')) {
      return CmdConsole(
        "WebApp Version: v${WaServer.info.version}\n" +
            "Dart Version: v${Platform.version}",
      );
    }

    if (controller.existsOption('update')) {
      await Process.start(
        'dart',
        ['pub', 'global', 'activate', 'webapp'],
        mode: ProcessStartMode.inheritStdio,
      );
      return CmdConsole("Update WebApp");
    }

    return CmdConsole(
      controller.manager.getHelp(),
      controller.existsOption('help') ? Colors.none : Colors.warnnig,
    );
  }
}
