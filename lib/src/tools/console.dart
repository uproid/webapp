import 'package:logger/logger.dart';

class Console {
  static final _logger = Logger(level: Level.debug);

  static void w(object) {
    _logger.w(object);
    _writeLog(object);
  }

  static void e(object) {
    _logger.e(object);
    _writeLog(object);
  }

  static void i(object) {
    _logger.i(object);
    _writeLog(object);
  }

  static void p(object) {
    _logger.f(object);
    _writeLog(object);
  }

  static void d(object) {
    _logger.d(object);
    _writeLog(object);
  }

  static void _writeLog(object) {
    write(object);
  }

  static void write(obj) => print(obj);

  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
