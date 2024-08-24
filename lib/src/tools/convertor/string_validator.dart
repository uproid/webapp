extension StringValidator on String {
  bool get isEmail {
    const regex =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    return RegExp(regex).hasMatch(this);
  }

  bool get isPassword {
    if (length < 8) {
      return false;
    }

    RegExp alphaExp = RegExp(r'[a-zA-Z]');
    RegExp digitExp = RegExp(r'\d');
    RegExp specialExp = RegExp(r'[!@#\$%\^&\*=]');
    if (!alphaExp.hasMatch(this) ||
        !digitExp.hasMatch(this) ||
        !specialExp.hasMatch(this)) {
      return false;
    }

    return true;
  }

  bool get toBool {
    String value = trim().toLowerCase();
    if (value == "1") {
      return true;
    }

    if (value == 'true') {
      return true;
    }

    return false;
  }

  int toInt({var def = -1}) {
    return int.tryParse(this) ?? def;
  }

  bool get isInt {
    return toInt(def: -99999999) != -99999999;
  }
}
