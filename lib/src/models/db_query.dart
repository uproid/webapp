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
    return {
      '\$regex': value,
      '\$options': options,
    };
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
}
