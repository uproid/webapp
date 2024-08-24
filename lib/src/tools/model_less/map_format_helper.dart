import 'dart:convert';
import 'mode_less_array.dart';
import 'model_less.dart';

extension MapFormatHelper on Map {
  int asInt(String key, {int def = 0}) {
    if (keys.contains(key)) {
      return int.tryParse(this[key].toString()) ?? def;
    }

    return def;
  }

  dynamic asAny(String key, {required dynamic def}) {
    if (keys.contains(key)) {
      return this[key];
    }

    return def;
  }

  double asDouble(String key, {double def = 0}) {
    if (keys.contains(key)) {
      return double.tryParse(this[key].toString()) ?? def;
    }

    return def;
  }

  num asNum(String key, {num def = 0}) {
    if (keys.contains(key)) {
      return num.tryParse(this[key].toString()) ?? def;
    }

    return def;
  }

  String asString(String key, {String def = ''}) {
    if (keys.contains(key)) {
      return this[key] ?? def;
    }

    return def;
  }

  bool asBool(String key, {def = false}) {
    if (keys.contains(key)) {
      if (this[key] is bool) {
        return this[key];
      } else if (this[key] is String) {
        var val = this[key].toString().trim().toLowerCase();
        if (val == 'true' || val == '1' || val.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      } else if (this[key] is int) {
        return (this[key] as int) > 0;
      }
    }

    return def;
  }

  List<T> asList<T>(String key, {List<T>? def}) {
    try {
      if (keys.contains(key)) {
        return List<T>.from(this[key].map((x) => x));
      }
    } catch (e) {
      return def ?? [];
    }
    return def ?? [];
  }

  Map<T, K> asMap<T, K>(String key, {Map<T, K>? def}) {
    try {
      return Map<T, K>.from(this[key]);
    } catch (e) {
      return def ?? {};
    }
  }

  List<T> asListModel<T>(
    String key,
    T Function(dynamic data) delegate, {
    List<T>? def,
  }) {
    List<T> result = [];
    try {
      if (keys.contains(key)) {
        List<dynamic> map = this[key];
        for (var value in map) {
          result.add(delegate(value));
        }

        return result;
      }
    } catch (e) {
      return def ?? [];
    }
    return def ?? [];
  }

  List<T> asListModelLess<T>(
    String key,
    T Function(ModelLess data) delegate, {
    List<T>? def,
  }) {
    List<T> result = [];
    try {
      if (keys.contains(key)) {
        ModelLessArray map = this[key];
        map.forEach<ModelLess>((val) {
          result.add(delegate(val));
        });

        return result;
      }
    } catch (e) {
      return def ?? [];
    }
    return def ?? [];
  }

  T asEnum<T>(
    String key,
    List<T> enumValues, {
    required T def,
    String Function(String data)? stringCleaner,
  }) {
    if (keys.contains(key) && this[key] != null) {
      T res = enumValues.firstWhere(
        (element) {
          String value = this[key];
          if (stringCleaner != null) {
            value = stringCleaner(value);
          }
          return element.toString() == '$T.$value';
        },
        orElse: () => def,
      );
      return res;
    }

    return def;
  }

  RegExp asRegex(
    String key, {
    String def = r'(\w+)',
    bool isBase64 = true,
    bool multiline = true,
  }) {
    try {
      if (isBase64) {
        var regexBase64 = asString('regex');
        var regexString = utf8.decode(base64Decode(regexBase64));
        if (regexString.isNotEmpty) {
          return RegExp(
            regexString,
            multiLine: multiline,
          );
        }
      }
      return RegExp(asString(key, def: r'(\w+)'));
    } catch (e) {
      return RegExp(r'(\w+)');
    }
  }
}
