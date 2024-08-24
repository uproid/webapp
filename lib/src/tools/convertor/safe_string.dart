import 'package:encrypt/encrypt.dart';

extension SafeString on String {
  String removeHtmlTags({String replace = ''}) {
    RegExp exp = RegExp(r"<[^>]*>([^<]*)<\/[^>]*>",
        multiLine: true, caseSensitive: true);
    String sanitized = replaceAll(exp, replace);
    return sanitized;
  }

  String removeScripts() {
    final RegExp scriptTagRegExp =
        RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>');
    final RegExp scriptAttrRegExp = RegExp(r'(?:\b|_)on\w+');

    // Remove any script tags from the input
    var input = replaceAll(scriptTagRegExp, '');

    // Remove any event handler attributes (e.g. onmousedown, onclick) from all elements
    final StringBuffer sb = StringBuffer();
    int start = 0;
    for (Match match in scriptAttrRegExp.allMatches(input)) {
      sb.write(input.substring(start, match.start));
      start = match.end;
    }
    sb.write(input.substring(start));

    return sb.toString();
  }

  String toSafe(String password) {
    try {
      if (password.length > 32) {
        password = password.substring(0, 32);
      } else if (password.length < 32) {
        while (password.length != 32) {
          password += '-';
        }
      }

      var key = Key.fromUtf8(password);

      password = password.substring(0, 16);
      final iv = IV.fromUtf8(password);

      final e = Encrypter(AES(key, mode: AESMode.cbc));
      final encryptedData = e.encrypt(this, iv: iv);
      return encryptedData.base64;
    } catch (e) {
      return '';
    }
  }

  String fromSafe(String password) {
    try {
      if (password.length > 32) {
        password = password.substring(0, 32);
      } else if (password.length < 32) {
        while (password.length != 32) {
          password += '-';
        }
      }

      var key = Key.fromUtf8(password);

      password = password.substring(0, 16);
      final iv = IV.fromUtf8(password);

      final e = Encrypter(AES(key, mode: AESMode.cbc));
      final decryptedData = e.decrypt(Encrypted.fromBase64(this), iv: iv);
      return decryptedData;
    } catch (e) {
      return e.toString();
    }
  }
}
