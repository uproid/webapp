import 'package:webapp/src/cli/commands/commands.dart';
import 'package:webapp/src/cli/commands/create.dart';
import 'package:webapp/src/cli/commands/main.dart';
import 'package:webapp/src/cli/core/cmd_controller.dart';
import 'package:webapp/src/cli/core/cmd_manager.dart';
import 'package:webapp/src/cli/core/option.dart';

void main(List<String> args) async {
  final cmdManager = CmdManager(
    args: args,
    main: CmdController(
      '',
      options: [
        Option(
          name: 'help',
          description: 'Show the help',
          shortName: 'h',
        ),
        Option(
          name: 'version',
          description: 'WebApp Version',
          shortName: 'v',
        ),
        Option(
          name: 'update',
          description: 'Update WebApp',
          shortName: 'u',
        ),
      ],
      run: (controller) => Main().main(controller),
    ),
    controllers: [
      CmdController(
        'create',
        description: 'Make new project',
        options: [
          /// TODO We have already just one template ('example-webapp-docker')
          // Option(
          //   name: 'template',
          //   shortName: 't',
          //   description: 'Template name',
          // ),
          Option(
            name: 'path',
            shortName: 'p',
            description: 'Path of the project',
          ),
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
        run: (controller) => CreateProject().create(controller),
      ),
      CmdController(
        'get',
        description: 'Get pacakges of project, (dart pub get)',
        run: (controller) => ProjectCommands().get(controller),
        options: [],
      ),
      CmdController(
        'runner',
        description:
            'Build runner of project, (dart pub run build_runner build)',
        run: (controller) => ProjectCommands().runner(controller),
        options: [],
      ),
      CmdController(
        'run',
        description: 'Run project, (dart run)',
        run: (controller) => ProjectCommands().run(controller),
        options: [
          Option(
            name: 'path',
            shortName: 'p',
            description: 'Path of app file',
          ),
        ],
      ),
      CmdController(
        'test',
        description: 'Unit test of project, (dart test)',
        run: (controller) => ProjectCommands().test(controller),
        options: [
          Option(
            name: 'reporter',
            shortName: 'r',
            description: 'Set how to print test results',
          ),
        ],
      ),
    ],
  );

  cmdManager.process();
}
