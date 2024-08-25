class LMap {
  Map<String, Object?> map;
  Object? def;
  LMap(this.map, {this.def});

  Object? operator [](String key) {
    if (map.keys.contains(key)) {
      return map[key];
    }

    if (def is String) {
      return def.toString().replaceAll('@key', key);
    }

    return def;
  }
}
