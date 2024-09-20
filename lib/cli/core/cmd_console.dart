import 'dart:io';

class CmdConsole {
  dynamic output;
  Colors color;
  bool space;

  CmdConsole(this.output, [this.color = Colors.info, this.space = false]);
  log() {
    var space = this.space ? '\n\n' : '';
    switch (color) {
      case Colors.warnnig:
        print('\x1B[33m$space$output$space\x1B[0m');
        break;
      case Colors.error:
        print('\x1B[31m$space$output$space\x1B[0m');
        break;
      case Colors.success:
        print('\x1B[32m$space$output$space\x1B[0m');
        break;
      case Colors.info:
        print('\x1B[36m$space$output$space\x1B[0m');
        break;
      case Colors.none:
        print(output);
      default:
        print(output);
    }
  }

  static write(dynamic obj, [Colors color = Colors.none, space = false]) {
    CmdConsole("${space ? '\n\n' : ''}$obj${space ? '\n\n' : ''}", color).log();
  }

  static void clear() {
    if (Platform.isWindows) {
      Process.runSync('cls', [], runInShell: true);
    } else {
      stdout.write('\x1B[2J\x1B[0;0H');
    }
  }

  static String read(
    String message, {
    bool isRequired = false,
    bool isNumber = false,
    bool isSlug = false,
  }) {
    stdout.write('\n\n$message ');
    var res = stdin.readLineSync() ?? '';
    res = res.trim();
    if (res.isEmpty && isRequired) {
      return read(
        message,
        isRequired: isRequired,
        isNumber: isNumber,
        isSlug: isSlug,
      );
    }

    if (isNumber) {
      var num = int.tryParse(res);
      if (num == null) {
        write("Input most be Integer!", Colors.error);
        return read(
          message,
          isRequired: isRequired,
          isNumber: isNumber,
          isSlug: isSlug,
        );
      }

      res = num.toString();
    }

    if (isSlug && !_isSlug(res)) {
      write("input should be slug (like: example_name)", Colors.error);
      return read(
        message,
        isRequired: isRequired,
        isNumber: isNumber,
        isSlug: isSlug,
      );
    }

    return res;
  }

  static bool _isSlug(String str) {
    var res = str.trim().toLowerCase();
    RegExp regex = RegExp(r'[^a-z]');
    res = res.replaceAll(regex, '');
    return res == str;
  }

  static Future<T> progress<T>(
    String message,
    Future<T> Function() action,
  ) async {
    bool isLoading = true;
    bool isWindows = Platform.isWindows;

    Future<void> showSpinner() async {
      String spinner(int index) {
        var res = '';
        var back = '█';
        var front = '░';
        for (var i = 0; i < 30; i++) {
          if (i == index) {
            res += front;
          } else {
            res += back;
          }
        }
        return res;
      }

      int spinnerIndex = 0;

      if (!isWindows) {
        stdin.echoMode = false;
        stdin.lineMode = false;
      }

      while (isLoading) {
        stdout.write('\r$message ${spinner(spinnerIndex)}');
        spinnerIndex = (spinnerIndex + 1) % 30;
        await Future.delayed(Duration(milliseconds: 50));
      }
    }

    var spinnerFuture = showSpinner();

    try {
      T result = await action();
      return result;
    } finally {
      if (!isWindows) {
        stdin.echoMode = true;
        stdin.lineMode = true;
      }
      isLoading = false;
      await spinnerFuture;
      stdout.write('\r$message Done!                            \n');
    }
  }

  static String select(
    String message,
    List<String> options, {
    bool isRequired = false,
  }) {
    stdout.writeln('\n\n$message\n');
    for (var i = 0; i < options.length; i++) {
      stdout.writeln("  ${i + 1}. ${options[i]}");
    }

    var res = read("Enter the number of the option:");
    var num = int.tryParse(res);
    if ((num == null || num < 1 || num > options.length) && isRequired) {
      write("Invalid option!", Colors.error);
      return select(message, options, isRequired: isRequired);
    }

    return num != null && options.length > num - 1 ? options[num - 1] : '';
  }

  static bool yesNo(String message) {
    var res = read("$message (y/n):");
    if (res.toLowerCase() == 'yes' || res.toLowerCase() == 'y') {
      return true;
    } else if (res.toLowerCase() == 'no' || res.toLowerCase() == 'n') {
      return false;
    } else {
      write("Invalid option!", Colors.error);
      return yesNo(message);
    }
  }
}

enum Colors {
  none,
  warnnig,
  error,
  success,
  info,
}
