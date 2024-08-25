import 'package:json_annotation/json_annotation.dart';

class DateTimeConverter implements JsonConverter<DateTime, DateTime?> {
  const DateTimeConverter();

  @override
  DateTime fromJson(DateTime? json) =>
      json ?? DateTime.parse('2000-01-01 00:00');

  @override
  DateTime? toJson(DateTime object) => object;
}
