import 'package:mongo_dart/mongo_dart.dart';
import 'package:webapp/src/db/mongo/error_codes.dart';
import 'package:webapp/src/forms/db_form_free.dart';
import 'package:webapp/wa_model.dart';
import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_tools.dart';
import 'package:webapp/wa_ui.dart';

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

  Future<FormResultFree> validate(
    Map<String, Object?> data, {
    List<String> onlyCheckKeys = const [],
  }) async {
    return form.validate(
      data,
      onlyCheckKeys: onlyCheckKeys,
    );
  }

  Future<FormResultFree> insert(Map<String, Object?> data) async {
    var validationResult = await validate(data);
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

    FormResultFree validationResult = await validate(data);
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

  Future<FormResultFree?> mergeOne(
    String id,
    Map<String, Object?> data,
  ) async {
    var oldData = await getById(id);

    if (oldData == null) {
      return null;
    }

    FormResultFree validationResult = await validate(
      data,
      onlyCheckKeys: data.keys.toList(),
    );
    var newData = validationResult.formValues();
    var mergedData = {
      ...oldData,
      ...newData,
    };
    if (validationResult.success) {
      var result = await collection.replaceOne(
        where.id(id.oID!),
        mergedData,
        upsert: false,
      );

      var newUpdate = await getById(id);
      if (result.isSuccess && newUpdate != null) {
        validationResult.updateValues(newUpdate);
      }
      return validationResult;
    } else {
      return await validate(mergedData);
    }
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
    var result = collection.modernFind(
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

    await for (var element in result) {
      results.add(await toModel(element, selectedFields: selectedFields));
    }

    return results;
  }

  /// Checks if a document with the given ID exists in the collection.
  ///
  /// The [idField] should be a valid MongoDB ObjectId string.
  ///
  /// Returns `true` if the document exists, otherwise `false`.
  Future<bool> existId(String idField) async {
    var id = ObjectId.tryParse(idField);
    return existOid(id);
  }

  Future<bool> existOid(ObjectId? id) async {
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
    FormResultFree formResult = await newForm.validate({field: value});

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
    return getByOid(oid);
  }

  Future<Map<String, Object?>?> getByOid(ObjectId? oid) async {
    if (oid == null || !await existOid(oid)) {
      return null;
    }

    var res = await collection.findOne(where.id(oid));
    if (res != null) {
      return await toModel(res);
    }
    return null;
  }

  Future<Map<String, Object?>> toModel(
    Map<String, Object?> document, {
    List<String>? selectedFields,
  }) async {
    FormResultFree formResult = await validate(document);
    var res = formResult.formValues(selectedFields: selectedFields);
    return res;
  }

  Future<FormResultFree> toFormResult(Map<String, Object?> document) async {
    return await validate(document);
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
                def: form.fields[key]!.defaultValue?.call(),
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

  /// Generate list of all routes for an API collection.
  List<WebRoute> routes(
    String path, {
    required WebRequest rq,
    bool useRouteAll = true,
    bool useRouteDelete = true,
    bool useRouteInsert = true,
    bool useRouteUpdate = true,
    bool useRouteGetOne = true,
    bool paging = true,
    int pageSize = 20,
    bool orderReverse = true,
    String orderBy = '_id',
    Future<ApiDoc>? Function()? docAll,
    Future<ApiDoc>? Function()? docDelete,
    Future<ApiDoc>? Function()? docInsert,
    Future<ApiDoc>? Function()? docUpdate,
    Future<ApiDoc>? Function()? docOne,
    List<WebRoute> children = const [],
  }) {
    return <WebRoute>[
      if (children.isNotEmpty)
        WebRoute(
          rq: rq,
          path: path,
          children: children,
        ),
      if (useRouteAll)
        routeGetAll(
          '$path',
          rq: rq,
          paging: paging,
          pageSize: pageSize,
          orderReverse: orderReverse,
          orderBy: orderBy,
          apiDoc: docAll,
        ),
      if (useRouteGetOne) routeGetOne('$path/{id}', rq: rq, apiDoc: docOne),
      if (useRouteDelete)
        routeDeleteOne(
          '$path/delete/{id}',
          rq: rq,
          apiDoc: docDelete,
        ),
      if (useRouteInsert) routeInsert('$path', rq: rq, apiDoc: docInsert),
      if (useRouteUpdate) routeUpdate('$path/{id}', rq: rq, apiDoc: docUpdate),
    ];
  }

  WebRoute routeGetAll(String path,
      {required WebRequest rq,
      List<String> methods = const [RequestMethods.GET],
      Future<ApiDoc>? Function()? apiDoc,
      WaAuthController? auth,
      List<String> extraPath = const [],
      List<String> excludePaths = const [],
      List<String> hosts = const ['*'],
      Map<String, Object?> params = const {},
      List<String> permissions = const [],
      List<int> ports = const [],
      List<WebRoute> children = const [],
      bool paging = true,
      int pageSize = 20,
      bool orderReverse = true,
      String orderBy = '_id'}) {
    final index = () async {
      if (paging == false) {
        var all = await getAll(
          filter: getSearchableFilter(inputs: rq.getAllData()),
        );

        return rq.renderData(data: {
          'success': true,
          'data': all,
        });
      } else {
        final countAll = await getCount(
          filter: getSearchableFilter(inputs: rq.getAllData()),
        );
        pageSize = rq.get<int>('pageSize', def: pageSize);
        orderBy = rq.get<String>('orderBy', def: orderBy);
        orderReverse = rq.get<bool>('orderReverse', def: orderReverse);

        UIPaging paging = UIPaging(
          rq: rq,
          total: countAll,
          pageSize: pageSize,
          widget: '',
          page: rq.get<int>('page', def: 1),
          orderReverse: orderReverse,
          orderBy: orderBy,
        );

        final res = await getAll(
          filter: getSearchableFilter(inputs: rq.getAllData()),
          limit: paging.pageSize,
          skip: paging.start,
          sort: DQ.order(orderBy, orderReverse),
        );

        return rq.renderData(data: {
          'success': true,
          'data': res,
          'paging': await paging.renderData(),
        });
      }
    };

    return WebRoute(
      path: path,
      methods: methods,
      rq: rq,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
      children: children,
    );
  }

  WebRoute routeInsert(
    String path, {
    required WebRequest rq,
    List<String> methods = const [RequestMethods.POST],
    Future<ApiDoc>? Function()? apiDoc,
    WaAuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    final index = () async {
      var res = await insert(rq.getAllData());

      if (!res.success) {
        return rq.renderData(
          data: {
            'form': res.toJson(),
            'success': false,
            'message': 'error',
          },
          status: 502,
        );
      }

      return rq.renderData(data: {
        'data': res.formValues(),
        'success': true,
        'message': 'inserted',
      });
    };

    return WebRoute(
      path: path,
      methods: methods,
      rq: rq,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
  }

  WebRoute routeUpdate(
    String path, {
    required WebRequest rq,
    List<String> methods = const [RequestMethods.POST],
    Future<ApiDoc>? Function()? apiDoc,
    WaAuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    final index = () async {
      var id = rq.getParam('id', def: '').toString();

      if (id.isEmpty) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id is required',
          },
          status: 502,
        );
      }

      var res = await replaceOne(id, rq.getAllData());
      if (res == null) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id not found',
          },
          status: 404,
        );
      }

      if (!res.success) {
        return rq.renderData(
          data: {
            'form': res.toJson(),
            'success': false,
            'message': 'error',
          },
          status: 502,
        );
      }

      return rq.renderData(data: {
        'data': res.formValues(),
        'success': true,
        'message': 'updated',
      });
    };

    return WebRoute(
      path: path,
      methods: methods,
      rq: rq,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
  }

  WebRoute routeDeleteOne(
    String path, {
    required WebRequest rq,
    List<String> methods = const [RequestMethods.GET],
    Future<ApiDoc>? Function()? apiDoc,
    WaAuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    final index = () async {
      var id = rq.getParam('id', def: '').toString();

      if (id.isEmpty) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id is required',
          },
          status: 502,
        );
      }

      var data = await delete(id);
      if (!data) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id not found',
          },
          status: 404,
        );
      }

      return rq.renderData(data: {
        'success': true,
        'message': 'deleted',
      });
    };

    return WebRoute(
      path: path,
      methods: methods,
      rq: rq,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
  }

  WebRoute routeGetOne(
    String path, {
    required WebRequest rq,
    List<String> methods = const [RequestMethods.GET],
    Future<ApiDoc>? Function()? apiDoc,
    WaAuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    final index = () async {
      var id = rq.getParam('id', def: '').toString();

      if (id.isEmpty) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id is required',
          },
          status: 502,
        );
      }

      var data = await getById(id);
      if (data == null) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id not found',
          },
          status: 404,
        );
      }

      return rq.renderData(data: {
        'success': true,
        'data': data,
        'message': 'ok',
      });
    };

    return WebRoute(
      path: path,
      methods: methods,
      rq: rq,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
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
