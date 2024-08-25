import 'package:webapp/wa_server.dart';
import 'package:webapp/src/widgets/wa_string_widget.dart';

class ErrorWidget implements WaStringWidget {
  static final _vs = WaServer.config.variableStart;
  static final _ve = WaServer.config.variableEnd;
  static final _bs = WaServer.config.blockStart;
  static final _be = WaServer.config.blockEnd;

  @override
  final String layout =
      /** @HTML */ '''
<!DOCTYPE html>
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
        <th style="$_vs 'background-color: #ffc5c5' if 'file://' in item $_ve">
          $_vs '›' if 'file://' in item $_ve
        </th>
        <td style="color: $_vs 'red' if 'file://' in item else '#555'$_ve;
                 padding: 10px; border-bottom: 1px solid #cccccc;margin-bottom: 10px;">
          <code style="word-break: break-all;">$_vs item $_ve</code>
        </td>
      </tr>
      $_bs endif $_be
      $_bs endfor $_be
    </tbody>
  </table>
  $_bs endif $_be
</body>

</html>
''';
}
