import 'package:webapp/cli/commands/commands.dart';
import 'package:webapp/cli/commands/create.dart';
import 'package:webapp/cli/core/cmd_controller.dart';
import 'package:webapp/cli/core/cmd_manager.dart';
import 'package:webapp/cli/core/option.dart';

void main(List<String> args) async {
  final cmdManager = CmdManager(
    args: args,
    controllers: [
      CmdController(
        'create',
        description: 'Make new project',
        options: [
          // Option(
          //   name: 'template',
          //   shortName: 't',
          //   description: 'Template name',
          // ),
          // Option(
          //   name: 'version',
          //   shortName: 'v',
          //   description: 'Version',
          // ),
          // Option(
          //   name: 'path',
          //   shortName: 'p',
          //   description: 'Path of the project',
          // ),
          Option(
            name: 'name',
            shortName: 'n',
            description: 'Name of project',
          ),
          Option(
            name: 'docker',
            shortName: 'd',
            description: 'Use docker',
          ),
        ],
        run: (controller) {
          return CreateProject().create(controller);
        },
      ),
      // CmdController(
      //   'route',
      //   description: 'Make new project',
      //   options: [
      //     Option(
      //       name: 'list',
      //       shortName: 'l',
      //       description: 'Get list of routes',
      //     ),
      //   ],
      //   run: (controller) {
      //     return RouteProject().route(controller);
      //   },
      // ),
      CmdController(
        'get',
        description: 'Get pacakges of project, (dart pub get)',
        run: (controller) {
          return ProjectCommands().get(controller);
        },
        options: [],
      ),
      CmdController(
        'runner',
        description:
            'Build runner of project, (dart pub run build_runner build)',
        run: (controller) {
          return ProjectCommands().runner(controller);
        },
        options: [],
      ),
      CmdController(
        'run',
        description: 'Run project, (dart run)',
        run: (controller) {
          return ProjectCommands().run(controller);
        },
        options: [
          Option(
            name: 'path',
            shortName: 'p',
            description: 'Path of app file',
          ),
        ],
      ),
    ],
  );

  cmdManager.process();
}
