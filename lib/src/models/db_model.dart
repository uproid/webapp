import 'package:mongo_dart/mongo_dart.dart';

abstract class DBModel {
  Future<Map<String, Object?>> toParams({Db? db});

  static Future<List<Map<String, Object?>>> toListParams(List<DBModel> list,
      {Db? db}) async {
    var res = <Map<String, Object?>>[];
    for (var element in list) {
      res.add(await element.toParams(db: db));
    }
    return res;
  }
}
