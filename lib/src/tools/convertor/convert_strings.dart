import 'dart:convert';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';

extension ConvertString on String {
  String toMd5() {
    List<int> bytes = utf8.encode(this);
    Digest md5Result = md5.convert(bytes);
    String md5String = md5Result.toString();
    return md5String;
  }

  String fromBase64({String def = ''}) {
    try {
      List<int> bytes = base64.decode(this);
      return utf8.decode(bytes);
    } catch (e) {
      return def;
    }
  }

  String fromBase32({String def = ''}) {
    try {
      return base32.decodeAsString(this);
    } catch (e) {
      return def;
    }
  }

  String toBase64() {
    return base64.encode(codeUnits);
  }

  String toBase32() {
    return base32.encodeString(this);
  }

  ObjectId? get oID => ObjectId.tryParse(trim());

  String toSlug() {
    String slug = trim().toLowerCase();
    slug = slug.replaceAll(RegExp(r'\s+'), '-');
    slug = slug.replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    return slug;
  }

  bool isSlug() {
    return this == toSlug();
  }
}

extension ConvertMap on Map {
  String joinMap(String separator, String separatorEntries) {
    var res = "";
    forEach((key, value) {
      res = "${res.isEmpty ? '' : "$res$separatorEntries"}$key$separator$value";
    });
    return res;
  }
}
