import 'package:webapp/wa_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'example_model.g.dart';

@JsonSerializable()
class ExampleModel implements DBModel {
  @JsonKey(name: '_id')
  @IDConverter()
  final String id;
  @JsonKey(defaultValue: "")
  final String title;
  @JsonKey(defaultValue: "")
  final String slug;

  ExampleModel({
    this.id = "",
    this.title = "",
    this.slug = "",
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);

  static List<ExampleModel> fromListJson(
    List<Map<String, dynamic>>? listJson,
  ) {
    List<ExampleModel> res = [];
    if (listJson != null) {
      for (var json in listJson) {
        res.add(ExampleModel.fromJson(json));
      }
    }
    return res;
  }

  Map<String, dynamic> toJson() {
    return _$ExampleModelToJson(this);
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  Future<Map<String, Object?>> toParams({Db? db}) async {
    return <String, Object?>{
      'id': id,
      'title': title,
      'slug': slug,
    };
  }
}
