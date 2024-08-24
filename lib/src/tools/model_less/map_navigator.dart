import '../console.dart';

extension MapPath on Map<String, dynamic> {
  T navigation<T>({
    required String path,
    required T def,
  }) {
    List<String> arrPath = path.split('/');
    return _navigationArray(
      map: this,
      pathArray: arrPath,
      def: def,
    );
  }

  T _navigationArray<T>({
    required dynamic map,
    required List<String> pathArray,
    required T def,
  }) {
    if (pathArray.isEmpty) {
      return _valueCheck<T>(value: map, def: def);
    }

    var key = pathArray.removeAt(0);

    if (map is Map<String, dynamic> && map.containsKey(key)) {
      return map._navigationArray<T>(
        map: map[key],
        pathArray: pathArray,
        def: def,
      );
    }

    var index = int.tryParse(key);
    if (map is List && index != null && map.length > index) {
      if (pathArray.isNotEmpty) {
        return _navigationArray<T>(
          map: map[index],
          pathArray: pathArray,
          def: def,
        );
      }
      return _valueCheck<T>(value: map[index], def: def);
    }

    return def;
  }

  T _valueCheck<T>({
    required dynamic value,
    required T def,
  }) {
    try {
      if (value == null) {
        return def;
      }

      if (T == String) {
        return value.toString() as T;
      }

      if (T == int) {
        return num.tryParse(value.toString()) as T;
      }

      if (T == double) {
        return double.tryParse(value.toString()) as T;
      }

      if (T == Map) {
        return (values) as T;
      }

      if (T == List) {
        return value;
      }

      if (T == Object) {
        return value;
      }

      //Develop here your other types of variables.
    } catch (e) {
      Console.w(e);
      return def;
    }

    return def;
  }
}
