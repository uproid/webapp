import 'dart:convert';
import 'package:webapp/wa_tools.dart';
import 'package:webapp/src/render/web_request.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Provides utility methods for encoding and decoding JSON data.
///
/// The [WaJson] class includes static methods for converting data to JSON format and
/// parsing JSON strings into Dart objects. It handles custom encoding for specific types
/// such as `TString`, `ObjectId`, `DateTime`, and `Duration`.
class WaJson {
  /// Converts an object to a JSON-encoded string.
  ///
  /// This method uses [jsonEncode] to serialize the [data] object into a JSON string.
  /// It provides custom encoding for specific types:
  /// - [TString]: Uses the [write] method with the optional [rq] parameter.
  /// - [ObjectId]: Converts to its string representation via the [oid] property.
  /// - [DateTime]: Converts to its ISO-8601 string representation.
  /// - [Duration]: Converts to its string representation.
  ///
  /// [data] is the object to be encoded.
  /// [rq] is an optional [WebRequest] object used for encoding [TString] instances.
  ///
  /// Returns a [String] containing the JSON-encoded representation of the [data] object.
  static String jsonEncoder(Object data, {WebRequest? rq}) {
    return jsonEncode(data, toEncodable: (obj) {
      if (obj == null) {
        return null;
      }
      if (obj is TString) {
        return obj.write(rq!);
      }
      if (obj is ObjectId) {
        return obj.oid;
      }
      if (obj is DateTime) {
        return obj.toString();
      }
      if (obj is Duration) {
        return obj.toString();
      }

      if (obj is Map) {
        return encodeMaps(obj, rq: rq);
      }
      if (obj is Symbol) {
        return symbolToKey(obj);
      }
      if (obj is int) {
        return obj;
      }
      return obj.toString();
    });
  }

  /// Convert Symbol maps to String maps
  static Map encodeMaps(Map obj, {WebRequest? rq}) {
    var res = {};
    for (Object o in obj.keys) {
      var key = "";
      if (o is Symbol)
        key = symbolToKey(o);
      else
        key = o.toString();
      res[key] = obj[o];
    }
    return res;
  }

  static String symbolToKey(Symbol symbol) {
    var name = symbol.toString();
    var regExp = RegExp(r'\("(.+)"\)');
    var match = regExp.firstMatch(name)?.group(1);
    match = match != null ? "#$match" : null;
    return match ?? name;
  }

  static Object? _jsonEncodelEvent(
    Object? key,
    Object? value,
  ) {
    if (value is Map) {
      return _normalizeMapKeys(value);
    }
    return value;
  }

  /// Parses a JSON-encoded string into a Dart object.
  ///
  /// This method uses [jsonDecode] to convert the [data] string from JSON format into
  /// a Dart object. The structure of the returned object depends on the contents of
  /// the JSON string.
  ///
  /// [data] is the JSON string to be decoded.
  ///
  /// Returns a dynamic object representing the parsed JSON data.
  static dynamic jsonDecoder(String data) {
    final map = jsonDecode(
      data,
      reviver: _jsonEncodelEvent,
    );

    return _normalizeMapKeys(map);
  }

  static _normalizeMapKeys(Map map) {
    var res = {};
    for (var key in map.keys) {
      final value = map[key];
      if (key is String && key.startsWith("#")) {
        key = key.substring(1);
        res[Symbol(key)] = value;
      } else {
        res[key] = value;
      }
    }

    return res;
  }

  /// Parses a JSON-encoded dynamic into a Dart object.
  static Map<T, V>? tryJson<T, V>(dynamic data, {WebRequest? rq}) {
    try {
      var res = jsonEncoder(data, rq: rq);
      return jsonDecoder(res) as Map<T, V>;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
