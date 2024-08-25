import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';

class IDConverter implements JsonConverter<String, ObjectId?> {
  const IDConverter();

  @override
  String fromJson(ObjectId? json) {
    return json == null ? '' : json.oid;
  }

  @override
  ObjectId? toJson(String object) {
    return object.isEmpty ? null : ObjectId.tryParse(object);
  }
}
