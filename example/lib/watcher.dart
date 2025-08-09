import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';
import 'package:stream_transform/stream_transform.dart';
import 'app.dart' as app;

main() async {
  runZonedGuarded(() async {
    app.main();

    var observatoryUri = (await dev.Service.getInfo()).serverUri;
    if (observatoryUri != null) {
      var serviceClient = await vmServiceConnectUri(
        convertToWebSocketUrl(serviceProtocolUrl: observatoryUri).toString(),
        log: StdoutLog(),
      );

      var vm = await serviceClient.getVM();
      var mainIsolate = vm.isolates!.first;
      serviceClient.setIsolatePauseMode(mainIsolate.id!,
          exceptionPauseMode: "None");

      Watcher(Directory.current.path)
          .events
          .throttle(const Duration(milliseconds: 1000))
          .listen((_) async {
        await serviceClient.reloadSources(mainIsolate.id ?? '');
        print('Reload source codes ${DateTime.now()}');
      });
    } else {
      print(
          'You need to pass `--enable-vm-service --disable-service-auth-codes` to enable hot reload');
    }
  }, (error, stackTrace) {
    // Handle errors here
    print('Caught an error: $error');
    print('Stack trace: $stackTrace');
    // Optionally, you can log the error or take other actions
  });
}

class StdoutLog extends Log {
  void warning(String message) => print("Watcher warning: " + message);
  void severe(String message) => print("Watcher severe: " + message);
}
