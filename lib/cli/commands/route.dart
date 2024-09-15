import 'package:webapp/wa_cli.dart';

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
