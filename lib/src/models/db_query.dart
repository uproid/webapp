import 'package:dartweb/dw_tools.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Database Query
class DQ {
  static Object? eq(Object? value) {
    return value;
  }

  static Map<String, Object?> or(List<Object?> list) {
    return {
      '\$or': list,
    };
  }

  static Map<String, Object?> oid(ObjectId id) {
    return {
      '_id': id,
    };
  }

  static Map<String, Object?> id(String id) {
    return {
      '_id': id.oID,
    };
  }

  static Map<String, Object?> and(List<Object?> list) {
    return {
      '\$and': list,
    };
  }

  static Map<String, Object?> hasIn(Object? value) {
    return {
      '\$in': value,
    };
  }

  static Map<String, Object?> hasNin(Object? value) {
    return {
      '\$nin': value,
    };
  }

  static Map<String, Object?> like(String value, {String options = 'i'}) {
    return {
      '\$regex': value,
      '\$options': options,
    };
  }

  static Map<String, Object?> field(String name, Object? query) {
    return {
      name: query,
    };
  }

  static Map<String, Object> group(Map<String, Object?> query) {
    return {'\$group': query};
  }

  static Map<String, Object>? order(
    String? orderBy, [
    bool orderReverse = true,
  ]) {
    if (orderBy == null || orderBy.isEmail) {
      return null;
    }
    return {orderBy: orderReverse ? -1 : 1};
  }

  static Map<String, Object?> sum(String field) {
    return {'\$sum': '\$$field'};
  }
}
