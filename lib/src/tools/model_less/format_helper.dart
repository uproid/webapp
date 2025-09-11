import 'package:mongo_dart/mongo_dart.dart';
import 'package:webapp/src/tools/console.dart';
import 'package:webapp/src/tools/convertor/convert_strings.dart';
import 'package:webapp/src/tools/convertor/string_validator.dart';

extension FormatHelper on dynamic {
  int asInt({int? def}) {
    return int.tryParse(toString()) ?? def ?? 0;
  }

  double asDouble({double? def}) {
    return double.tryParse(toString()) ?? def ?? 0.0;
  }

  num asNum({num? def}) {
    return num.tryParse(toString()) ?? def ?? 0;
  }

  String asString({String? def, bool trim = true}) {
    def ??= '';
    var res = (this ?? def).toString();
    if (trim) {
      res = res.trim();
    }
    return res.isEmpty ? def : res;
  }

  bool asBool({bool? def}) {
    var value = this ?? def;
    return value.toString().toBool;
  }

  List<T> asList<T>({List<T>? def}) {
    try {
      if (T == ObjectId) {
        final res = <ObjectId>[];

        for (var e in this) {
          if (e is ObjectId) {
            res.add(e);
          } else if (e is String) {
            ObjectId? oid = e.toString().oID;
            if (oid != null) {
              res.add(oid);
            }
          }
        }

        return res as List<T>;
      }
      if (this is List) {
        return List<T>.from(map((x) => x));
      }

      if (this is String) {
        var res = (toString()).split(',').map((e) {
          if (T == String) {
            return e.toString().trim() as T;
          }
          return e as T;
        }).toList();
        res.removeWhere((element) => element == null || element == '');
        return res;
      }

      if (this is T) {
        return [this as T];
      }
      return def ?? [];
    } catch (e) {
      Console.e(e);
      return def ?? [];
    }
  }

  ObjectId asObjectId({ObjectId? def}) {
    if (this is ObjectId) {
      return this;
    }

    var res = toString().trim();
    res = res.replaceAll('ObjectId("', '').replaceAll('")', 'replace');
    return res.oID ?? def ?? ObjectId();
  }

  DateTime? asDateTime({DateTime? def}) {
    var value = this ?? def;
    if (value == null) {
      return DateTime.utc(1977);
    }
    var res = DateTime.tryParse(value.toString().trim());
    return res;
  }

  T? asCast<T>({T? def}) {
    var value = this as Object?;
    if (value == null) {
      return def;
    }

    switch (T.toString()) {
      case 'int':
        return value.asInt(def: def as int) as T;
      case 'double':
        return value.asDouble(def: def as double) as T;
      case 'num':
        return value.asNum(def: def as num) as T;
      case 'String':
        return value.asString(def: def as String) as T;
      case 'bool':
        return value.asBool(def: def as bool) as T;
      case 'List':
        return value.asList(def: def as List) as T;
      case 'ObjectId':
        return value.asObjectId(def: def as ObjectId) as T;
      case 'DateTime':
        return value.asDateTime(def: def as DateTime) as T;
      case 'int?':
        int? defVal = (def) as int?;
        return value.asInt(def: defVal) as T?;
      case 'double?':
        var defVal = (def) as double?;
        return value.asDouble(def: defVal) as T?;
      case 'num?':
        var defVal = (def) as num?;
        return value.asNum(def: defVal) as T?;
      case 'String?':
        var defVal = (def) as String?;
        return value.asString(def: defVal) as T?;
      case 'bool?':
        var defVal = (def) as bool?;
        return value.asBool(def: defVal) as T?;
      case 'List?':
        var defVal = (def) as List?;
        return value.asList(def: defVal) as T?;
      case 'ObjectId?':
        var defVal = (def) as ObjectId?;
        return value.asObjectId(def: defVal) as T?;
      case 'DateTime?':
        var defVal = (def) as DateTime?;
        return value.asDateTime(def: defVal) as T?;
      default:
        return def;
    }
  }
}
