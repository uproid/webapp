import 'package:mongo_dart/mongo_dart.dart';

abstract class DBCollection {
  String name;
  Db db;
  DbCollection get collection => db.collection(name);

  DBCollection({required this.name, required this.db}) {
    db.getCollectionNames().then((coll) async {
      if (!coll.contains(name)) {
        await db.createCollection(name);
      }
    });
  }

  Future<bool> existId(String idField) async {
    var id = ObjectId.tryParse(idField);
    if (id == null) return false;
    var count = await collection.count(where.id(id));
    return count > 0;
  }

  Future<bool> exist(String field, Object value) async {
    return await getCount(field: field, value: value) > 0;
  }

  Future<int> getCount({
    String? field,
    Object? value,
    Map<String, Object?>? filter,
  }) async {
    if (field != null && value != null) {
      var count = await collection.modernCount(
          selector: where.eq(field, value), filter: filter);
      return count.count;
    }
    return (await collection.modernCount(filter: filter)).count;
  }

  Future<bool> get isEmpty async => (await getCount()) == 0;
  Future<bool> get isNotEmpty async => !(await isEmpty);

  Future<bool> delete(String id) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var res = await collection.deleteOne(where.id(oid));
      return res.success;
    }

    return false;
  }

  Future<void> copy(String id) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var data = await collection.findOne(where.id(oid));
      if (data != null) {
        data.remove('_id');
        await collection.insertOne(data);
      }
    }
  }

  Future<void> updateField(String id, String field, Object? value) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null && await existId(id)) {
      await collection.updateOne(where.id(oid), modify.set(field, value));
    }
  }

  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var row = await collection.findOne(where.id(oid));
      if (row != null) {
        row.addAll(fields);
        await collection.modernUpdate(where.id(oid), row);
      }
    }
  }

  /// Update All Fields with a condition (filter)
  Future<void> updateAllForField({
    required String field,
    required Object? value,
    required Map<String, Object?>? filter,
  }) async {
    await collection.updateMany(
      filter,
      modify.set(field, value),
    );
  }
}
