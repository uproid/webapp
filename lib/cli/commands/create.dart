import 'dart:io';
import 'package:webapp/wa_tools.dart';
import '../core/cmd_controller.dart';
import '../core/cmd_console.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';

class CreateProject {
  String projectUrl =
      'https://github.com/uproid/example-webapp-docker/archive/refs/heads/master.zip';
  String savePath =
      '${Directory.systemTemp.path}/template_${DateTime.timestamp().microsecondsSinceEpoch}.zip';

  Future<CmdConsole> create(CmdController controller) async {
    var result = CmdConsole("Error in creating project", Colors.error);
    var name = controller.getOption('name');
    var isDocker = controller.existsOption('docker');
    var useDocker = false;

    if (!isDocker) {
      useDocker = CmdConsole.yesNo("Do you want to use docker?");
    } else {
      useDocker = true;
    }

    if (name.isEmpty) {
      name = CmdConsole.read(
        "Enter project name:",
        isRequired: true,
        isSlug: true,
      );
    }

    String pathZip = await CmdConsole.progress<String>("Waitng...", () async {
      return downloadFile(projectUrl, savePath);
    });

    if (pathZip.isNotEmpty) {
      var dirPrject = await extract("./$name");
      if (dirPrject.isNotEmpty) {
        await updatePacakge(
          dirPrject,
          name: name,
          useDocker: useDocker,
        );
        result = CmdConsole(
            "Project created successfully: $dirPrject", Colors.success);
      }
    }

    return result;
  }

  Future<String> downloadFile(String url, String savePath) async {
    try {
      // Make the HTTP GET request
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Create a file object
        final file = File(savePath);

        // Write the response body to the file
        await file.writeAsBytes(response.bodyBytes);

        return savePath;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<String> extract(String dir) async {
    try {
      final bytes = File(savePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          var newPath =
              filename.replaceFirst('example-webapp-docker-master', '');
          File(joinPaths([dir, newPath]))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(joinPaths([dir, filename])).createSync(recursive: true);
        }
      }

      Directory(joinPaths([dir, 'example-webapp-docker-master'])).deleteSync(
        recursive: true,
      );
      return dir;
    } catch (e) {
      return "";
    }
  }

  Future updatePacakge(
    String filePath, {
    required String name,
    required bool useDocker,
  }) async {
    final file = File(joinPaths([filePath, 'pubspec.yaml']));
    var pubspec = await file.readAsString();
    pubspec = pubspec.replaceFirst('name: example', 'name: $name');
    file.writeAsStringSync(pubspec, mode: FileMode.write);

    if (!useDocker) {
      final dockerFile = File(joinPaths([filePath, 'Dockerfile']));
      dockerFile.deleteSync();

      final dockerIgnore = File(joinPaths([filePath, '.dockerignore']));
      dockerIgnore.deleteSync();

      final dockerCompose = File(joinPaths([filePath, 'docker-compose.yaml']));
      dockerCompose.deleteSync();
    }
  }
}
