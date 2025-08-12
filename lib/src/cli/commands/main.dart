import 'dart:io';

import 'package:capp/capp.dart';
import 'package:webapp/src/wa_server.dart';

class Main {
  Future<CappConsole> main(CappController controller) async {
    if (controller.existsOption('version')) {
      return CappConsole(
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
      return CappConsole("Update WebApp");
    }

    return CappConsole(
      controller.manager.getHelp(),
      controller.existsOption('help') ? CappColors.none : CappColors.warning,
    );
  }
}
