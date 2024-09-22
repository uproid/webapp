import 'dart:io';
import 'package:logger/logger.dart';

/// A utility class for logging messages with different severity levels.
///
/// The [Console] class provides static methods for logging warnings, errors,
/// information, debugging messages, and fatal errors. The logs are managed using
/// the [Logger] package and optionally printed to the console.
///
/// Example usage:
/// ```dart
/// Console.i("This is an informational message.");
/// Console.e("This is an error message.");
/// ```
class Console {
  /// The [Logger] instance used for managing log messages.
  static final _logger = Logger(
    level: isTestRunning() ? Level.off : Level.debug,
    printer: PrettyPrinter(
      printEmojis: false,
    ),
  );

  /// Logs a warning message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void w(object) {
    _logger.w(object);
    _writeLog(object);
  }

  /// Logs an error message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void e(object) {
    _logger.e(object);
    _writeLog(object);
  }

  /// Logs an informational message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void i(object) {
    _logger.i(object);
    _writeLog(object);
  }

  /// Logs a fatal or critical error message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void p(object) {
    _logger.f(object);
    _writeLog(object);
  }

  /// Logs a debug message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void d(object) {
    _logger.d(object);
    _writeLog(object);
  }

  /// Writes the log to the console.
  ///
  /// This is a private method used internally by the logging methods
  /// to print the log message.
  static void _writeLog(object) {
    write(object);
  }

  /// Prints the given [obj] to the console.
  ///
  /// This method is public and can be used to directly print messages.
  static void write(obj) => print(obj);

  /// Checks if the application is running in debug mode.
  ///
  /// Returns `true` if in debug mode; otherwise, returns `false`.
  /// This is determined using the Dart `assert` statement.
  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static bool isTestRunning() {
    return Platform.environment['WEBAPP_IS_TEST'] == 'true';
  }
}
