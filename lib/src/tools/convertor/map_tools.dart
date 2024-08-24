extension MapTools<K, V> on Map<K, V> {
  /// remove all fields that are in this list.
  /// you can use `select` in place this if you need other fields.
  Map<K, V> removeAll(List<K> keys) {
    for (var key in keys) {
      remove(key);
    }
    return this;
  }

  /// Select all fields of map that are in this list
  Map<K, V> select(List<K> selectKeys) {
    Map<K, V> res = {};
    for (var entry in entries) {
      if (selectKeys.contains(entry.key)) res.add(entry);
    }
    return res;
  }

  ///Add one entry to a Map
  void add(MapEntry<K, V> entry) {
    this[entry.key] = entry.value;
  }
}
