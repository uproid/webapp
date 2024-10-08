import 'package:webapp/src/cli/core/cmd_manager.dart';

import 'option.dart';
import 'cmd_console.dart';

class CmdController {
  String name;
  String description;
  late CmdManager manager;

  List<Option> options = [];
  Future<CmdConsole> Function(CmdController args) run;

  CmdController(
    this.name, {
    this.description = '',
    required this.options,
    required this.run,
  });

  init({required CmdManager manager}) {
    this.manager = manager;
  }

  String getOption(String name, {String def = ''}) {
    for (var option in options) {
      if (option.name == name || option.shortName == name) {
        return option.value.isEmpty ? def : option.value;
      }
    }
    return def;
  }

  bool existsOption(String name) {
    for (var option in options) {
      if (option.name == name || option.shortName == name) {
        return option.existsInArgs;
      }
    }
    return false;
  }
}
