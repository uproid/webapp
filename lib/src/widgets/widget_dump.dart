import 'package:webapp/src/views/htmler.dart';
import 'package:webapp/src/widgets/wa_string_widget.dart';

/// A widget that provides an HTML layout for displaying error messages.
///
/// The [DumpWodget] class implements [WaStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class DumpWodget implements WaStringWidget {
  @override
  final String layout = '';

  @override
  Tag Function(Map args)? generateHtml = (args) {
    return Html()
      ..addChild(Jinja('if output'))
      ..addChild(
        Head()
          ..addChild(
            Script().addAttr(
              'src',
              'https://pfau-software.de/json-viewer/dist/iife/index.js',
            ),
          )
          ..addChild(
            Style().addChild(
              Text(
                'body { margin: 0; padding: 0; background-color: #151515; }',
              ),
            ),
          ),
      )
      ..addChild(
        Body()
          ..addChild(
            CustomTag('andypf-json-viewer', attrs: {
              'indent': '2',
              'show-data-types': 'true',
              'show-toolbar': 'true',
              'expand-icon-type': 'square',
              'show-copy': 'true',
              'show-size': 'true',
              'theme': 'summerfruit-dark',
              'expanded': '2',
            })
              ..addChild(
                JinjaVar("output"),
              ),
          ),
      )
      ..addChild(
        Jinja('endif'),
      );
  };
}
