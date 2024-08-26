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

      return obj.toString();
    });
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
    return jsonDecode(data);
  }
}
