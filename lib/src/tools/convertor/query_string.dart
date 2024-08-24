import 'dart:convert';

class QueryString {
  static Map<String, Object?> parse(String query, {Encoding encoding = utf8}) {
    var result = <String, Object?>{};
    result = query.split("&").fold(
      {},
      (map, element) {
        int index = element.indexOf("=");
        if (index == -1) {
          if (element != "") {
            map[Uri.decodeQueryComponent(element, encoding: encoding)] = "";
          }
        } else if (index != 0) {
          var key = element.substring(0, index);
          var value = element.substring(index + 1);
          var encodeKey = Uri.decodeQueryComponent(key, encoding: encoding);
          var encodeValue = Uri.decodeQueryComponent(value, encoding: encoding);
          var isArray = encodeKey.endsWith('[]');

          if (isArray) {
            encodeKey = encodeKey.substring(0, encodeKey.length - 2);
            if (map.keys.contains(encodeKey)) {
              if (map[encodeKey] is List) {
                (map[encodeKey] as List).add(encodeValue);
              } else {
                var list = [];
                list.add(map[encodeKey]);
                list.add(encodeValue);
                map[encodeKey] = list;
              }
            } else {
              map[encodeKey] = [encodeValue];
            }
          } else {
            map[encodeKey] = encodeValue;
          }
        }
        return map;
      },
    );
    return result;
  }
}
