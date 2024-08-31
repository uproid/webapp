import 'package:webapp/wa_server.dart';
import 'package:webapp/src/widgets/wa_string_widget.dart';

/// A widget that provides an HTML layout for displaying error messages.
///
/// The [DumpWodget] class implements [WaStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class DumpWodget implements WaStringWidget {
  /// The start delimiter for variables in the HTML layout.
  static final _vs = WaServer.config.variableStart;

  /// The end delimiter for variables in the HTML layout.
  static final _ve = WaServer.config.variableEnd;

  /// The start delimiter for blocks in the HTML layout.
  static final _bs = WaServer.config.blockStart;

  /// The end delimiter for blocks in the HTML layout.
  static final _be = WaServer.config.blockEnd;

  /// The HTML layout for the error widget.
  ///
  /// This layout is used to render an error page with a standard structure, including:
  /// - A title indicating an error status.
  /// - Basic styling for the error page content.
  /// - A section for displaying error details and stack traces if available.
  ///
  /// The layout includes the following HTML elements:
  /// - `DOCTYPE html` declaration and basic HTML structure.
  /// - Meta tags for character set, compatibility, and viewport settings.
  /// - A styled `body` with error message and optional debugging information.
  /// - A table for displaying error details and stack traces.
  ///
  /// The layout utilizes placeholders for dynamic content:
  /// - `$_vs` and `$_ve` for variable interpolation.
  /// - `$_bs` and `$_be` for conditional blocks. [html]
  @override
  final String layout = /*html*/ """$_bs if output $_be
  <!DOCTYPE html>
  <html>
    <head>
      <script src="https://pfau-software.de/json-viewer/dist/iife/index.js"></script>
      <style>
        body {
          margin: 0;
          padding: 0;
          background-color: #151515;
        }
      </style>
    </head>
    <body>
      <andypf-json-viewer
        indent="2"
        expanded="true"
        show-data-types="true"
        show-toolbar="true"
        expand-icon-type="square"
        show-copy="true"
        show-size="true"
        theme="summerfruit-dark"
        expanded="2"
      >
      $_vs output $_ve
      </andypf-json-viewer>
    </body>
  </html>
  $_bs endif $_be
  """;
}
