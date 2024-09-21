import 'package:webapp/src/cli/core/cmd_console.dart';
import 'package:webapp/src/cli/core/cmd_controller.dart';

class RouteProject {
  Future<CmdConsole> route(CmdController controller) async {
    var showList = controller.existsOption('list');
    if (showList) {
      return _showList();
    }

    return CmdConsole("Route project", Colors.success);
  }

  Future<CmdConsole> _showList() async {
    return CmdConsole("List of routes", Colors.info);
  }
}
