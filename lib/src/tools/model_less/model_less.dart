import 'dart:convert';
import 'package:dartweb/src/tools/console.dart';
import 'package:dartweb/src/tools/convertor/string_validator.dart';
import 'mode_less_array.dart';

class ModelLess {
  Map<String, dynamic> fields = {};
  dynamic Function(dynamic value)? onGet;
  ModelLess({Map<String, dynamic>? fields, this.onGet}) {
    if (fields != null) {
      this.fields.addAll(fields);
    }
  }

  void remove(String key) {
    fields.remove(key);
  }

  Object? operator [](String key) {
    if (!fields.keys.contains(key)) {
      return '';
    }
    var value = fields[key];
    if (onGet != null) {
      value = onGet!(value);
    }
    return value;
  }

  void operator []=(String key, dynamic value) {
    set(key, value);
  }

  T get<T>(String key, {T? def}) {
    if (key.contains('/')) {
      return getByPathString<T>(key);
    } else {
      if (this[key] == null) {
        return def as T;
      }
      if (T == String) {
        if (this[key].toString().isEmpty) return (def ?? '') as T;
        return this[key].toString() as T;
      }
      if (T == int) {
        var res = int.tryParse(this[key].toString());
        if (res != null) {
          return res as T;
        }
        return def as T;
      }

      if (T == List) {
        if (this[key] is T) {
          return this[key] as T;
        } else {
          return def as T;
        }
      }

      if (T == DateTime) {
        if (this[key] is T) {
          return this[key] as T;
        } else {
          return def as T;
        }
      }

      if (T == bool) {
        if (this[key] is String) {
          return this[key].toString().toBool as T;
        } else if (this[key] is T) {
          return this[key] as T;
        } else if (this[key] == null && def == null) {
          return false as T;
        } else {
          return def as T;
        }
      }

      return this[key] as T;
    }
  }

  /// the path is a array of path nodes
  T getByPath<T>(List<dynamic> path, {dynamic def}) {
    try {
      var key = path.removeAt(0);
      if (path.isEmpty) {
        return get<T>(key, def: def);
      } else {
        if (path[0] is int) {
          var index = path.removeAt(0) as int;
          var valueKey = get<dynamic>(key);
          var valueIndex = valueKey.get<dynamic>(index);

          if ((valueIndex is ModelLess || valueIndex is ModelLessArray) &&
              path.isNotEmpty) {
            return valueIndex.getByPath<dynamic>(path, def: def);
          }
          return valueIndex as T;
        }
        return get<ModelLess>(key).getByPath<T>(path, def: def);
      }
    } catch (e) {
      Console.e(e);
      if (T == String && def == null) {
        return "" as T;
      }
      return def as T;
    }
  }

  /// the path is a String path fot access to a node. for example "posts/news/1/title"
  T getByPathString<T>(String path, {dynamic def}) {
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

    return getByPath<T>(arr, def: def);
  }

  /// add or set a new node to the model
  void set(String key, dynamic value) {
    fields[key] = value;
  }

  /// making a new model from a json string
  factory ModelLess.fromJson(String jsonString) {
    return ModelLess.fromMap(json.decode(jsonString));
  }

  factory ModelLess.fromDynamic(dynamic val) {
    return ModelLess.fromMap(Map<String, dynamic>.from(val));
  }

  /// making a new model from a map
  factory ModelLess.fromMap(Map map) {
    ModelLess apiModels = ModelLess();
    map.forEach((key, value) {
      if (value is List) {
        apiModels.set(key, ModelLessArray.fromList(value));
      } else if (value is Map) {
        apiModels.set(key, ModelLess.fromMap(value));
      } else {
        apiModels.set(key, value);
      }
    });

    return apiModels;
  }

  @override
  String toString() => fields.toString();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> f = {};
    fields.forEach((key, value) {
      if (value is DateTime) {
        f[key] = value.toString();
      } else {
        f[key] = value;
      }
    });

    return f;
  }

  static List<Map<String, dynamic>> toListMap(List<ModelLess> list) {
    List<Map<String, dynamic>> res = [];
    for (var l in list) {
      res.add(l.toMap());
    }
    return res;
  }
}
