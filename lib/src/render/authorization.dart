import 'package:dartweb/src/tools/convertor/convert_strings.dart';

class Authorization {
  AuthType type;
  String value;

  Authorization({
    this.type = AuthType.none,
    this.value = '',
  });

  factory Authorization.parse(String auth) {
    final splitedAuth = auth.split(' ');
    if (splitedAuth.length <= 1) {
      return Authorization(type: AuthType.none);
    }

    final typeString = splitedAuth[0].trim().toLowerCase();
    if (typeString == 'basic') {
      return Authorization(
        type: AuthType.basic,
        value: splitedAuth[1].fromBase64(),
      );
    }

    if (typeString == 'bearer') {
      return Authorization(
        type: AuthType.basic,
        value: splitedAuth[1],
      );
    }

    return Authorization();
  }

  String getBasicUsername() {
    var arr = value.split(':');
    if (arr.length >= 2) {
      return arr[0];
    }

    return '';
  }

  String getBasicPassword() {
    var arr = value.split(':');
    if (arr.length >= 2) {
      return arr[1];
    }

    return '';
  }

  @override
  String toString() {
    return "Type: $type, Value:$value";
  }
}

enum AuthType {
  none,
  basic,
  bearer,
  digest,
  hawk,
  //AWS4_HMAC_SHA256,
  aws,
  //EG1-HMAC-SHA256
  akamai,
}
