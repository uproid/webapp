import 'cmd_controller.dart';
import 'cmd_console.dart';
import 'option.dart';

class CmdManager {
  List<CmdController> controllers;
  List<String> args;
  CmdController main;
  CmdManager({
    required this.main,
    required this.args,
    required this.controllers,
  });

  void process() async {
    if (args.isEmpty) {
      CmdConsole.write("No command provided", Colors.error);
      return;
    }
    try {
      for (var controller in controllers) {
        controller.init(manager: this);

        if (controller.name == args[0]) {
          for (var option in controller.options) {
            final find = _findOptionValue(args, option);
            option.value = find.value;
            option.existsInArgs = find.exist;
          }

          var res = await controller.run(controller);
          res.log();
          return;
        }
      }

      main.init(manager: this);
      for (var option in main.options) {
        final find = _findOptionValue(args, option);
        option.value = find.value;
        option.existsInArgs = find.exist;
      }

      var res = await main.run(main);
      res.log();
      return;
    } catch (e) {
      CmdConsole.write("Error: ${e.toString()}", Colors.error);
    }
    CmdConsole.write(getHelp(), Colors.warnnig);
  }

  String getHelp() {
    var help = "Available commands:\n";

    for (var controller in [main, ...controllers]) {
      if (controller.name.isNotEmpty) {
        help += "> ${controller.name}:\t${controller.description}\n\n";
      } else {
        help += "${controller.description}\n\n";
      }

      for (var option in controller.options) {
        help += "   --${option.name}:\t${option.description}\n";
        if (option.shortName.isNotEmpty) {
          help += "   -${option.shortName}\n\n";
        } else {
          help += "\n";
        }
      }
    }

    return help;
  }

  ({String value, bool exist}) _findOptionValue(
      List<String> args, Option option) {
    var exist = false;
    for (var i = 0; i < args.length; i++) {
      var arg = args[i];
      if (arg.startsWith('--${option.name}') ||
          arg.startsWith('-${option.shortName}')) {
        exist = true;

        if (args.length > i + 1) {
          var nextArg = args[i + 1];
          if (!nextArg.startsWith('-')) {
            return (value: nextArg, exist: exist);
          }
        }
      }
    }
    return (value: option.value, exist: exist);
  }
}
