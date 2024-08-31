import 'dart:convert';

import '../console.dart';
import 'model_less.dart';

/// The ModelLessArray class is a generic class that provides a structure for
/// managing a collection of items, specifically designed to work with ModelLess
/// objects. This class offers features such as accessing items by index,
/// dynamically setting and getting values, parsing JSON into the array, and
/// retrieving nested data using paths. Below is an explanation and breakdown
/// of the key features:
class ModelLessArray<T> {
  List<T>? fields;

  ModelLessArray({this.fields});

  get length {
    return fields == null ? 0 : fields!.length;
  }

  void forEach<R>(T Function(R val) function) {
    for (int i = 0; i < length; i++) {
      function(get<R>(i));
    }
  }

  bool get isNotEmpty => length > 0;

  bool get isEmpty => length == 0;

  dynamic operator [](int index) {
    if (fields == null) {
      return null;
    }

    if (fields!.length <= index) {
      return null;
    }

    return fields![index];
  }

  void operator []=(int index, T value) {
    fields ??= <T>[];
    if (fields!.length <= index) {
      throw Exception('Index out of range: $index');
    } else {
      fields![index] = value;
    }
  }

  // ignore: avoid_shadowing_type_parameters
  T get<T>(int index, {dynamic def}) {
    var val = this[index];

    if (val == null) {
      return def as T;
    }

    return val as T;
  }

  void set(dynamic value) {
    fields ??= <T>[];
    fields!.add(value);
  }

  void addAll(ModelLessArray<T> value) {
    fields ??= <T>[];
    fields!.addAll(value.fields!);
  }

  static ModelLessArray<T> fromJson<T>(String jsonString) {
    ModelLessArray<T> arrayApiModels = ModelLessArray();

    try {
      List<dynamic> jsonData = json.decode(jsonString);
      for (var element in jsonData) {
        ModelLess apiModel = ModelLess.fromMap(element);
        arrayApiModels.set(apiModel);
      }
    } on Exception catch (e) {
      Console.write("Error Parsing Data for init an ArrayApiModel: $e");
    }

    return arrayApiModels;
  }

  static ModelLessArray<T>? tryJson<T>(String jsonString) {
    try {
      List<dynamic> jsonData = json.decode(jsonString);
      ModelLessArray<T> arrayApiModels = ModelLessArray();
      for (var element in jsonData) {
        ModelLess apiModel = ModelLess.fromMap(element);
        arrayApiModels.set(apiModel);
      }
      return arrayApiModels;
    } catch (e) {
      return null;
    }
  }

  R getByPath<R>(List<dynamic> path, {dynamic def}) {
    try {
      var key = path.removeAt(0);
      if (path.isEmpty) {
        return get<R>(key, def: def);
      } else {
        if (path[0] is int) {
          var index = path.removeAt(0) as int;
          var valueKey = get<dynamic>(key);
          var valueIndex = valueKey.get<dynamic>(index);

          if ((valueIndex is ModelLess || valueIndex is ModelLessArray) &&
              path.isNotEmpty) {
            return valueIndex.getByPath<dynamic>(path, def: def);
          }
          return valueIndex as R;
        }
        return get<ModelLess>(key).getByPath<R>(path, def: def);
      }
    } catch (e) {
      if (T == String && def == null) return "" as R;
      return def as R;
    }
  }

  R getByPathString<R>(String path, {dynamic def}) {
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    if (path.startsWith('/')) {
      path = path.substring(1, path.length);
    }

    List<dynamic> arr = <dynamic>[];
    for (var element in Uri(path: path).pathSegments) {
      arr.add(int.tryParse(element) ?? element);
    }
    return getByPath<R>(arr, def: def);
  }

  @override
  String toString() {
    return fields == null ? "[]" : fields.toString();
  }

  static ModelLessArray fromList(List list) {
    ModelLessArray arrayApiModels = ModelLessArray();
    for (var element in list) {
      if (element is Map) {
        arrayApiModels.set(ModelLess.fromDynamic(element));
      } else {
        arrayApiModels.set(element);
      }
    }

    return arrayApiModels;
  }

  void clear() {
    fields ??= <T>[];
    fields!.clear();
  }
}
