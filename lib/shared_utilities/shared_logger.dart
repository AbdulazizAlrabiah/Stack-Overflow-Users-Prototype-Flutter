import 'package:logger/logger.dart';

class SharedLogger {
  SharedLogger._();
  static final SharedLogger shared = SharedLogger._();

  final _logger = Logger();

  // info
  void i(String message) {
    _logger.i(message);
  }

  // warning
  void w(String message) {
    _logger.w(message);
  }

  // error
  void e(String message) {
    _logger.e(message);
  }

  // debug
  void d(String message) {
    _logger.d(message);
  }
}
