import 'dart:convert';
import 'dart:io';
import 'package:dweb/src/tools/console.dart';
import 'package:path/path.dart' as p;

class MultiLanguage {
  String languagePath;
  MultiLanguage(this.languagePath);

  Future<Map<String, Map<String, String>>> init() async {
    final directory = Directory(languagePath);
    Map<String, Map<String, String>> result = await _findFiles(directory, {});
    return result;
  }

  Future<Map<String, Map<String, String>>> _findFiles(
    Directory dir,
    Map<String, Map<String, String>> result,
  ) async {
    var entities = dir.listSync();
    for (var entry in entities) {
      if (entry is File) {
        var ext = p.extension(entry.path).toLowerCase();

        if (ext == '.json') {
          var fileData = await readFile(entry.path, result);
          result = {...result, ...fileData};
        }
      } else if (entry is Directory) {
        var fileData = await _findFiles(entry, result);
        result = {...result, ...fileData};
      }
    }

    return result;
  }

  Future<Map<String, Map<String, String>>> readFile(
    String path,
    Map<String, Map<String, String>> result,
  ) async {
    try {
      File file = File(path);
      String filename = p.basenameWithoutExtension(path);
      String jsonString = await file.readAsString();

      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      Map<String, String> map = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      result[filename] = map;
      return result;
    } catch (e) {
      Console.e({'error': e});
    }

    return {};
  }
}
