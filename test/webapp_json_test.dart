import 'package:test/test.dart';
import 'package:webapp/src/tools/convertor/serializable/value_converter/json_value.dart';

void main() {
  group('Group WaJson', () {
    test("Test encode", () async {
      var map = {
        'a': 1,
        'e': [
          1,
          2,
          {
            #d: 1,
            #e: 2,
          }
        ],
        'f': {'a': 1, 'b': 2},
        #h: 6,
        #i: {
          #a: 'a',
          #b: 'b',
          #c: {
            #d: 1,
            #e: 2,
          }
        },
      };

      var jsonString = WaJson.jsonEncoder(map);
      var json = WaJson.jsonDecoder(jsonString);

      expect(map, json, reason: 'This two json should be equal');
    });
  });
}
