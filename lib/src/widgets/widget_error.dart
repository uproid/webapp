import 'package:webapp/wa_server.dart';
import 'package:webapp/src/widgets/wa_string_widget.dart';

/// A widget that provides an HTML layout for displaying error messages.
///
/// The [ErrorWidget] class implements [WaStringWidget] and provides a predefined
/// HTML structure to be used for rendering error messages in the application.
/// It includes styles and structure for displaying error details and stack traces.
class ErrorWidget implements WaStringWidget {
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
  /// - `$_bs` and `$_be` for conditional blocks.
  @override
  final String layout = /*HTML*/ """<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <title>Error $_vs status $_ve</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    * {
      font-family: 'Courier New', Courier, monospace;
    }

    body {
      margin: 0;
      padding: 10px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
    }

    thead th {
      text-align: center !important;
      padding: 10px;
      border: 1px solid #ccc;
    }

    tbody th,
    table td {
      padding: 8px;
      border: 1px solid #ccc;
    }

    table th {
      background-color: #f2f2f2;
      font-weight: bold;
      text-align: left;
    }

    table td {
      font-size: smaller;
    }

    table tr:nth-child(even) {
      background-color: #f9f9f9;
    }

    table tr:hover {
      background-color: #e6e6e6;
    }

    .flag {
      text-align: center;
      max-width: 20px;
      padding: 3px;
    }

    a {
      text-decoration: none;
      color: inherit;
    }
  </style>
</head>

<body style="max-width: 100%;">
  <h1>&lt;&nbsp;Error $_vs status $_ve &nbsp;&sol;&gt;</h1>
  <p>Oops! Something went wrong. Please try again later.</p>
  $_bs if error and isLocalDebug $_be
  <div style="background-color: blanchedalmond;padding:30px 5px 30px 5px;border: 1px solid #ccc">
    <code style="word-break: break-all; font-weight: bold;margin:5px">$_vs error $_ve</code>
  </div>
  <table style="background-color: #eeeeee55;">
    $_bs if stack and (stack | length > 0) $_be
    <thead>
      <th colspan="2" class="text-align:center">Error details</th>
    </thead>
    $_bs endif $_be
    <tbody>
      $_bs for item in stack | default() $_be
      $_bs if item | length > 0 $_be
      <tr>
        <th class='flag' style="$_vs 'background-color: #ffc5c5' if 'file://' in item $_ve">
          $_bs if 'file://' in item $_be
          ⛔
          $_bs elif 'package:webapp' in item $_be
          <a target='_blank' title='Report to WebApp Developers' href='https://github.com/uproid/webapp/issues'>🐛</a>
          $_bs else $_be
          ⚪
          $_bs endif $_be
        </th>
        $_bs if 'file://' in item $_be
          <td style="color: red;padding: 10px; border-bottom: 1px solid #cccccc;margin-bottom: 10px;">
            <code class='vscode' style="word-break: break-all;">$_vs item $_ve</code>
          </td>
        $_bs else $_be
          <td style="color: #555;padding: 10px; border-bottom: 1px solid #cccccc;margin-bottom: 10px;">
            <code style="word-break: break-all;">$_vs item $_ve</code>
          </td>
        $_bs endif $_be
        
      </tr>
      $_bs endif $_be
      $_bs endfor $_be
    </tbody>
  </table>
  $_bs endif $_be
  <script>
  const vscodes = document.querySelectorAll('.vscode').forEach((element) => {
    const text = element.textContent;
    const regExp = "/\/\/([^)\*]+)";
    const match = text.match(regExp);
    if (match && match[1]) {
      element.innerHTML = `<a href="vscode://file/\${match[1]}">\${text}</a>`;
    } else {
      element.innerHTML = text;
    }
  });
  </script>
</body>

</html>""";
}
