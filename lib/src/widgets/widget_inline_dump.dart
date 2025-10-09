import 'package:webapp/src/views/htmler.dart';
import 'package:webapp/src/widgets/wa_string_widget.dart';
import 'package:webapp/wa_tools.dart';

/// A widget that provides an HTML layout for displaying error messages.
/// The [InlineDumpWidget] class implements [WaStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class InlineDumpWidget implements WaStringWidget {
  @override
  final String layout = '';

  @override
  Tag Function(Map args)? generateHtml = (args) {
    dynamic variable = args['var'];

    var res = ArrayTag(children: [
      $Style().addChild(
        $Raw('''.wa-debug-dump { 
              margin: 0; padding: 0; 
              background-color: #151515; 
              font-family: monospace; 
              font-size: 9px;
              border: 1px solid #333;
              border-radius: 5px;
              box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
            }
          '''),
      ),
      $Div(
        classes: ['wa-debug-dump'],
        children: [
          $CustomTag('andypf-json-viewer', attrs: {
            'indent': '2',
            'show-data-types': 'true',
            'show-toolbar': 'true',
            'show-copy': 'true',
            'theme': 'summerfruit-dark',
            'expanded': '2',
          }, children: [
            $Raw(WaJson.jsonEncoder(variable ?? 'N/A')),
          ]),
        ],
      ),
      $Script(attrs: {
        'src': 'https://pfau-software.de/json-viewer/dist/iife/index.js'
      }),
    ]);
    return res;
  };
}
