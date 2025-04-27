import 'package:capp/capp.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:webapp/src/db/mongo/error_codes.dart';
import 'package:webapp/src/forms/db_form_free.dart';
import 'package:webapp/wa_console.dart';
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
  static final List<DBCollectionFree> _allCollectionFree = [];

  static void printDesign() async {
    CappConsole.clear();
    var json = <String, Object?>{};
    for (var collection in _allCollectionFree) {
      var jsonCollection = <String, Object?>{};
      var fieldsJson = <String, Object?>{};
      for (var field in collection.form.fields.entries) {
        var fieldModel = field.value;
        fieldsJson.addAll({
          field.key: {
            'type': fieldModel.type,
            'default': fieldModel.defaultValue?.call(),
            'readonly': fieldModel.readonly,
            'searchable': fieldModel.searchable,
            'filterable': fieldModel.filterable,
            'validators': fieldModel.validators.length,
            'isHiddenJson': fieldModel.hideJson,
          },
        });
      }

      jsonCollection.addAll({
        'name': collection.name,
        'db': collection.db.databaseName,
        'count': await collection.collection.count(),
        'fields': fieldsJson,
        'events': {
          'onInsert': collection.collectionEvent.onInsert._listeners.length,
          'onUpdate': collection.collectionEvent.onUpdate._listeners.length,
          'onDelete': collection.collectionEvent.onDelete._listeners.length,
        },
        'indexes': await collection.collection.getIndexes(),
      });
      json[collection.name] = jsonCollection;
    }

    Console.json(json);
  }

  DBFormFree form;
  CollectionEvent collectionEvent = CollectionEvent();
  var indexes = <String, DBIndex>{};

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
  DBCollectionFree({
    required this.name,
    required this.db,
    required this.form,
    this.indexes = const {},
  }) {
    _allCollectionFree.add(this);

    db.getCollectionNames().then((coll) async {
      if (!coll.contains(name)) {
        await db.createCollection(name);
      }
      _renewIndexes();
    });
  }

  void _renewIndexes() async {
    if (indexes.isNotEmpty) {
      collection.getIndexes().then((res) async {
        for (var oldIndex in res) {
          await collection.dropIndexes(oldIndex['name']);
        }
        for (var key in indexes.keys) {
          var index = indexes[key]!;
          index.name ??= "_${key}_";

          await createIndex(
            background: index.background,
            dropDups: index.dropDups,
            keys: index.keys,
            name: index.name,
            partialFilterExpression: index.partialFilterExpression,
            sparse: index.sparse,
            unique: index.unique,
            modernReply: index.modernReply,
            key: index.key,
            collation: index.collation,
          );
        }
      });
    }
  }

  Future<Map<String, dynamic>> createIndex({
    String? key,
    Map<String, dynamic>? keys,
    bool? unique,
    bool? sparse,
    bool? background,
    bool? dropDups,
    Map<String, dynamic>? partialFilterExpression,
    String? name,
    bool? modernReply,
    Map<dynamic, dynamic>? collation,
  }) async {
    if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('Use createIndex() method on db (before 3.6)');
    }

    modernReply ??= true;
    var indexOptions = CreateIndexOptions(
      collection,
      uniqueIndex: unique == true,
      sparseIndex: sparse == true,
      background: background == true,
      dropDuplicatedEntries: dropDups == true,
      partialFilterExpression: partialFilterExpression,
      indexName: name,
      collation: collation,
    );

    var indexOperation =
        CreateIndexOperation(db, collection, _setKeys(key, keys), indexOptions);

    var res = await indexOperation.execute();
    if (res[keyOk] == 0.0) {
      // It should be better to create a MongoDartError,
      // but, for compatibility reasons, we throw the received map.
      throw res;
    }
    if (modernReply) {
      return res;
    }
    return db.getLastError();
  }

  Map<String, dynamic> _setKeys(String? key, Map<String, dynamic>? keys) {
    if (key != null && keys != null) {
      throw ArgumentError('Only one parameter must be set: key or keys');
    }

    if (key != null) {
      keys = {};
      keys[key] = 1;
    }

    if (keys == null) {
      throw ArgumentError('key or keys parameter must be set');
    }

    return keys;
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
        await collectionEvent.onInsert.emit(result.document);
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
        await collectionEvent.onUpdate.emit(newUpdate);
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
        await collectionEvent.onUpdate.emit(newUpdate);
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

    for (var element in await result.toList()) {
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
      return deleteOid(oid);
    }

    return false;
  }

  /// Deletes a document from the collection by its ID.
  ///
  /// The [id] should be a valid MongoDB ObjectId string.
  ///
  /// Returns `true` if the deletion was successful, otherwise `false`.
  Future<bool> deleteOid(ObjectId oid) async {
    var oldData = await getByOid(oid);
    var res = await collection.deleteOne(where.id(oid));
    var result = res.success && res.nRemoved == 1;
    if (result && oldData != null) {
      await collectionEvent.onDelete.emit(oldData);
    }
    return result;
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
        var result = await collection.insertOne(data);
        if (result.isSuccess) {
          await collectionEvent.onInsert.emit(result.document);
        }
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
        await collectionEvent.onUpdate.emit(newData);
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

class CollectionEvent {
  /// Event triggered when a document is inserted into the collection.
  final Event<Map<String, Object?>> onInsert = Event<Map<String, Object?>>();

  /// Event triggered when a document is updated in the collection.
  final Event<Map<String, Object?>> onUpdate = Event<Map<String, Object?>>();

  /// Event triggered when a document is deleted from the collection.
  final Event<Map<String, Object?>> onDelete = Event<Map<String, Object?>>();
}

typedef EventFunction<R> = void Function(R data);
typedef EventAsyncFunction<R> = Future<void> Function(R data);

class Event<T> {
  /// List of listeners for the event.
  final List<EventFunction<T>> _listeners = [];
  final List<EventAsyncFunction<T>> _asyncListeners = [];

  /// Adds a listener to the event.
  Event addListener(EventFunction listener) {
    _listeners.add(listener);
    return this;
  }

  /// Adds an asynchronous listener to the event.
  Event addAsyncListener(EventAsyncFunction listener) {
    _asyncListeners.add(listener);
    return this;
  }

  /// Emits the event, calling all registered listeners.
  Future<int> emit([dynamic data]) async {
    var i = 0;

    for (var listener in _listeners) {
      listener(data);
      i++;
    }

    for (var asyncListener in _asyncListeners) {
      await asyncListener(data);
      i++;
    }

    return i;
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

class DBIndex {
  String? key;
  Map<String, dynamic>? keys;
  bool? unique;
  bool? sparse;
  bool? background;
  bool? dropDups;
  Map<String, dynamic>? partialFilterExpression;
  String? name;
  bool? modernReply;
  Map<dynamic, dynamic>? collation;

  DBIndex({
    this.key,
    this.keys,
    this.unique,
    this.sparse,
    this.background,
    this.dropDups,
    this.partialFilterExpression,
    this.name,
    this.modernReply,
    this.collation,
  });
}
