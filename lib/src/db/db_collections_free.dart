import 'package:mongo_dart/mongo_dart.dart';
import 'package:webapp/src/db/mongo/error_codes.dart';
import 'package:webapp/src/forms/db_form_free.dart';
import 'package:webapp/wa_model.dart';

/// An abstract class representing a MongoDB collection with utility methods.
///
/// The `DBCollection` class provides an abstraction over a MongoDB collection,
/// offering various methods to interact with the database, such as checking for
/// the existence of a document by its ID, updating fields, and more. This class
/// is meant to be extended by other classes for more specific collection implementations.
abstract class DBCollectionFree {
  DBFormFree form;

  /// The name of the MongoDB collection.
  String name;

  /// The MongoDB database instance.
  Db db;

  /// Provides direct access to the underlying MongoDB collection.
  ///
  /// The collection is retrieved using the `db.collection(name)` method.
  DbCollection get collection => db.collection(name);

  /// Constructor to initialize the [name] of the collection and the [db] instance.
  ///
  /// When initialized, the constructor checks if the collection exists in the database,
  /// and creates it if it does not already exist.
  DBCollectionFree({required this.name, required this.db, required this.form}) {
    db.getCollectionNames().then((coll) async {
      if (!coll.contains(name)) {
        await db.createCollection(name);
      }
    });
  }

  FormResultFree validate(Map<String, Object?> data) {
    return form.validate(data);
  }

  Future<FormResultFree> insert(Map<String, Object?> data) async {
    var validationResult = validate(data);
    if (validationResult.success) {
      var result = await collection.insertOne(validationResult.formValues());

      if (!result.isFailure && result.document != null) {
        validationResult.updateValues(result.document!);
      } else {
        validationResult.updateFromMongoResponse(result.serverResponses);
      }
    }
    return validationResult;
  }

  Future<FormResultFree?> replaceOne(
    String id,
    Map<String, Object?> data,
  ) async {
    var oid = ObjectId.tryParse(id);
    if (oid == null || !await existId(id)) {
      return null;
    }

    FormResultFree validationResult = validate(data);
    if (validationResult.success) {
      var newData = validationResult.formValues();
      newData['_id'] = oid;
      var result = await collection.replaceOne(
        where.id(oid),
        newData,
      );
      var newUpdate = await getById(id);
      if (result.isSuccess && newUpdate != null) {
        validationResult.updateValues(newUpdate);
      }
    }

    return validationResult;
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

  Future<List<Map<String, Object?>>> getAll({
    SelectorBuilder? selector,
    Map<String, Object?>? filter,
    FindOptions? findOptions,
    String? hint,
    int? skip,
    Map<String, Object>? sort,
    int? limit,
    Map<String, Object>? hintDocument,
    Map<String, Object>? projection,
    Map<String, Object>? rawOptions,
  }) async {
    skip ??= 0;
    skip = skip < 1 ? null : skip;

    var results = <Map<String, Object?>>[];
    var result = await collection.modernFind(
      selector: selector,
      filter: filter,
      findOptions: findOptions,
      hint: hint,
      skip: skip,
      sort: sort,
      limit: limit,
      hintDocument: hintDocument,
      projection: projection,
      rawOptions: rawOptions,
    );

    List<String>? selectedFields;
    if (selector != null && selector.paramFields.isNotEmpty) {
      selectedFields = selector.paramFields.keys.toList();
    }

    await result.forEach((element) {
      results.add(toModel(element, selectedFields: selectedFields));
    });

    return results;
  }

  /// Checks if a document with the given ID exists in the collection.
  ///
  /// The [idField] should be a valid MongoDB ObjectId string.
  ///
  /// Returns `true` if the document exists, otherwise `false`.
  Future<bool> existId(String idField) async {
    var id = ObjectId.tryParse(idField);
    if (id == null) return false;
    var count = await collection.modernCount(selector: where.id(id));
    return count.count > 0;
  }

  /// Deletes a document from the collection by its ID.
  ///
  /// The [id] should be a valid MongoDB ObjectId string.
  ///
  /// Returns `true` if the deletion was successful, otherwise `false`.
  Future<bool> delete(String id) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var res = await collection.deleteOne(where.id(oid));
      return res.success && res.nRemoved == 1;
    }

    return false;
  }

  /// Creates a copy of a document by its ID and inserts it as a new document.
  ///
  /// The [id] should be a valid MongoDB ObjectId string. The copied document
  /// will have a new ObjectId assigned.
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

  /// Updates a specific field of a document by its ID.
  ///
  /// The [id] should be a valid MongoDB ObjectId string. The [field] specifies
  /// the field to be updated, and [value] is the new value to be assigned.
  Future<FormResultFree?> updateField(
    String id,
    String field,
    Object? value,
  ) async {
    var oid = ObjectId.tryParse(id);
    if (oid == null || !await existId(id)) {
      return null;
    }

    var fieldModel = form.fields[field];
    if (fieldModel == null) {
      return null;
    }

    DBFormFree newForm = DBFormFree(fields: {field: fieldModel});
    FormResultFree formResult = newForm.validate({field: value});

    if (formResult.success) {
      await collection.updateOne(where.id(oid), modify.set(field, value));
      var newData = await getById(id);
      if (newData != null) {
        return toFormResult(newData);
      }
    }

    return formResult;
  }

  Future<Map<String, Object?>?> getById(String id) async {
    var oid = ObjectId.tryParse(id);

    if (oid == null || !await existId(id)) {
      return null;
    }

    var res = await collection.findOne(where.id(oid));
    if (res != null) {
      return toModel(res);
    }
    return null;
  }

  Map<String, Object?> toModel(
    Map<String, Object?> document, {
    List<String>? selectedFields,
  }) {
    FormResultFree formResult = validate(document);
    var res = formResult.formValues(selectedFields: selectedFields);
    return res;
  }

  FormResultFree toFormResult(Map<String, Object?> document) {
    return validate(document);
  }

  Map<String, Object?> getSearchableFilter({
    required Map<String, Object?> inputs,
    String searchFiled = 'search',
  }) {
    var resSearch = <String, Object?>{};
    if (inputs[searchFiled] != null &&
        inputs[searchFiled].toString().trim().isNotEmpty) {
      var searchOr = [];
      for (var key in form.fields.keys) {
        if (form.fields[key]!.searchable) {
          searchOr.add(
            DQ.field(key, DQ.like(inputs[searchFiled].toString().trim())),
          );
        }
      }

      if (searchOr.isNotEmpty) {
        resSearch = DQ.or(searchOr);
      }
    }

    var resFilter = <String, Object?>{};
    var filterAnd = [];
    for (var key in form.fields.keys) {
      if (form.fields[key]!.filterable) {
        if (inputs[key] != null) {
          filterAnd.add(
            DQ.field(
              key,
              ObjectDescovery.descovr(
                inputs[key],
                form.fields[key]!.type,
                def: form.fields[key]!.defaultValue,
              ),
            ),
          );
        }
      }
    }
    if (filterAnd.isNotEmpty) {
      resFilter = DQ.and(filterAnd);
    }

    var res = <String, Object?>{};
    if (resSearch.isNotEmpty && resFilter.isNotEmpty) {
      res = DQ.and([resSearch, resFilter]);
    }
    res = {...resSearch, ...resFilter};
    return res;
  }
}

class MongoErrorResponse {
  static Map<String, List<String>> discoverError(
    List<Map<String, Object?>> response,
  ) {
    Map<String, List<String>> res = {};

    for (final resp in response) {
      if (resp.containsKey('writeErrors') && resp['writeErrors'] is List) {
        final writeErrors = resp['writeErrors'] as List;
        for (final writeError in writeErrors) {
          String error = mongoDBErrorCodes[writeError['code']]?[#name] ??
              'mongo.error.unknown';
          final Map<String, Object?> keyPattern =
              (writeError['keyPattern'] != null &&
                      writeError['keyPattern'] is Map)
                  ? writeError['keyPattern']
                  : {};
          List<String> fields = keyPattern.keys.toList();
          fields.forEach((field) {
            if (!res.containsKey(field)) {
              res[field] = [];
            }
            res[field]!.add(error);
          });
        }
      }
    }

    return res;
  }
}
