import 'package:webapp/wa_tools.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// A utility class for building MongoDB queries.
///
/// The [DQ] class provides a set of static methods to construct MongoDB-compatible queries
/// in a more readable and structured way. It allows for easy creation of complex queries
/// with operations such as equality checks, logical operations (`\$or`, `\$and`), pattern matching,
/// and aggregation commands like grouping and sorting.
///
/// Example Usage:
/// ```dart
/// var query = DQ.and([
///   DQ.field('name', DQ.like('John')),
///   DQ.field('age', DQ.eq(25)),
/// ]);
/// var result = await collection.find(query).toList();
/// ```
class DQ {
  /// Returns a value for equality comparison.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.eq('value'); // { 'field': 'value' }
  /// ```
  static Object? eq(Object? value) {
    return value;
  }

  /// Constructs a logical OR query.
  ///
  /// Takes a list of conditions and joins them using the `\$or` operator.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.or([DQ.eq('value1'), DQ.eq('value2')]); // { '\$or': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> or(List<Object?> list) {
    return {
      '\$or': list,
    };
  }

  /// Matches a document based on its ObjectId.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.oid(ObjectId.parse('507f191e810c19729de860ea')); // { '_id': ObjectId(...) }
  /// ```
  static Map<String, Object?> oid(ObjectId id) {
    return {
      '_id': id,
    };
  }

  /// Matches a document based on a string ID.
  ///
  /// Converts the string to an ObjectId using the `oID` extension.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.id('507f191e810c19729de860ea'); // { '_id': ObjectId(...) }
  /// ```
  static Map<String, Object?> id(String id) {
    return {
      '_id': id.oID,
    };
  }

  /// Constructs a logical AND query.
  ///
  /// Takes a list of conditions and joins them using the `\$and` operator.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.and([DQ.eq('value1'), DQ.eq('value2')]); // { '\$and': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> and(List<Object?> list) {
    return {
      '\$and': list,
    };
  }

  /// Matches documents where the field's value is in the provided list.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.hasIn(['value1', 'value2']); // { '\$in': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> hasIn(Object? value) {
    return {
      '\$in': value,
    };
  }

  /// Matches documents where the field's value is not in the provided list.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.hasNin(['value1', 'value2']); // { '\$nin': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> hasNin(Object? value) {
    return {
      '\$nin': value,
    };
  }

  /// Matches documents where the field's value matches a regular expression.
  ///
  /// The [options] parameter can be used to set regex options (e.g., `'i'` for case-insensitive).
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.like('pattern', options: 'i'); // { '\$regex': 'pattern', '\$options': 'i' }
  /// ```
  static Map<String, Object?> like(String value, {String options = 'i'}) {
    value = _escapeRegex(value);

    return {
      '\$regex': value,
      '\$options': options,
    };
  }

  /// Matches documents where the field's value is case-insensitive.
  ///
  /// This is a specialized version of the `like` method that uses a regex pattern to match the entire string.

  /// Example:
  /// ```dart
  /// var query = DQ.uncase('pattern'); // { '\$regex': '^pattern\$', '\$options': 'i' }
  /// ```
  /// This method is useful for case-insensitive exact matches.
  static Map<String, Object?> uncase(String value) {
    value = _escapeRegex(value);

    return {
      '\$regex': '^$value\$',
      '\$options': 'i',
    };
  }

  // Escape all special regex characters
  static String _escapeRegex(String input) {
    return input.replaceAllMapped(
      RegExp(r'[.*+?^${}()|[\]\\]'),
      (match) {
        return match.group(0) != null ? "\\${match.group(0)}" : '';
      },
    );
  }

  /// Constructs a query for a specific field.
  ///
  /// The [query] parameter defines the condition for the field.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.field('name', DQ.like('John')); // { 'name': { '\$regex': 'John', '\$options': 'i' } }
  /// ```
  static Map<String, Object?> field(String name, Object? query) {
    return {
      name: query,
    };
  }

  /// Constructs a MongoDB aggregation group stage.
  ///
  /// The [query] parameter should define the grouping operation.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.group({
  ///   '_id': '\$field',
  ///   'total': DQ.sum('field')
  /// }); // { '\$group': { '_id': '\$field', 'total': { '\$sum': '\$field' } } }
  /// ```
  static Map<String, Object> group(Map<String, Object?> query) {
    return {'\$group': query};
  }

  /// Constructs an order/sorting query for MongoDB.
  ///
  /// The [orderBy] parameter specifies the field to order by.
  /// The [orderReverse] parameter controls the sorting direction: descending (`-1`) if `true` (default), ascending (`1`) if `false`.
  ///
  /// Returns `null` if [orderBy] is `null` or invalid (e.g., an email).
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.order('field', true); // { 'field': -1 }
  /// ```
  static Map<String, Object>? order(
    String? orderBy, [
    bool orderReverse = true,
  ]) {
    if (orderBy == null || orderBy.isEmail) {
      return null;
    }
    return {orderBy: orderReverse ? -1 : 1};
  }

  /// Constructs a sum aggregation operation.
  ///
  /// The [field] parameter specifies the field to sum.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.sum('field'); // { '\$sum': '\$field' }
  /// ```
  static Map<String, Object?> sum(String field) {
    return {'\$sum': '\$$field'};
  }

  static Map<String, Object> lookup({
    required String from,
    required String localField,
    String foreignField = '_id',
    String? as,
  }) {
    as ??= '${from}_info';

    return {
      '\$lookup': {
        'from': from,
        'localField': localField,
        'foreignField': foreignField,
        'as': as,
      }
    };
  }

  static Map<String, Object> unwind({
    required String path,
    String? as,
    bool? preserveNullAndEmptyArrays,
  }) {
    if (as == null && preserveNullAndEmptyArrays == null) {
      return {'\$unwind': "\$$path"};
    }

    return {
      '\$unwind': {
        'path': "\$$path",
        if (preserveNullAndEmptyArrays != null)
          'preserveNullAndEmptyArrays': preserveNullAndEmptyArrays,
        if (as != null) 'as': as
      }
    };
  }

  static Map<String, Object> match(List<Map<String, Object?>> matches) {
    return {
      '\$match': {for (var match in matches) ...match}
    };
  }

  static Map<String, Object?> gt(Object? value) {
    return {
      '\$gt': value,
    };
  }

  static Map<String, Object?> gte(Object? value) {
    return {
      '\$gte': value,
    };
  }

  static Map<String, Object?> lt(Object? value) {
    return {
      '\$lt': value,
    };
  }

  static Map<String, Object?> lte(Object? value) {
    return {
      '\$lte': value,
    };
  }

  static List<Map<String, Object>> pipeline(
    List<Map<String, Object>> query,
  ) {
    return [...query];
  }

  static Map<String, Object> project(Map<String, Object> fields) {
    return {
      '\$project': {
        ...fields,
      }
    };
  }

  static Map<String, Object> sort(Map<String, int> fields) {
    return {
      '\$sort': {
        ...fields,
      }
    };
  }

  static Map<String, Object> sortList(List<Map<String, int>> fields) {
    return {
      '\$sort': {
        for (var field in fields) ...field,
      }
    };
  }

  static Map<String, Object> sortOne(String field, [bool desc = true]) {
    return sortList([
      sortField(field, desc),
    ]);
  }

  static Map<String, int> sortField(String field, [bool desc = true]) {
    return {
      field: desc ? -1 : 1,
    };
  }

  static Map<String, Object> limit(int limit) {
    return {
      '\$limit': limit,
    };
  }

  static Map<String, Object> skip(int skip) {
    if (skip < 0) {
      skip = 0;
    }
    return {
      '\$skip': skip,
    };
  }

  static Map<String, Object> count(String field) {
    return {
      '\$count': field,
    };
  }

  static Map<String, Object> dateToString({
    required Object field,
    String format = '%Y-%m-%d %H:%M:%S',
    Object? onNull,
    Object? onError,
    String? timezone,
  }) {
    return {
      '\$dateToString': {
        'format': format,
        'date': field,
        if (timezone != null) 'timezone': timezone,
        if (onNull != null) 'onNull': onNull,
        if (onError != null) 'onError': onError,
      }
    };
  }

  static Map<String, Object> toDate(
    String field,
  ) {
    return {'\$toDate': "\$$field"};
  }

  static Map<String, Object> sumQuery(
    Object query,
  ) {
    return {
      '\$sum': query,
    };
  }

  static Map<String, Object> cond({
    required Object ifCond,
    required Object thenCond,
    required Object elseCond,
  }) {
    return {
      '\$cond': {
        'if': ifCond,
        'then': thenCond,
        'else': elseCond,
      }
    };
  }

  static String $field(String field) {
    return "\$$field";
  }
}
