import 'dart:convert';
import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_tools.dart';

var localEvents = <String, Object>{
  'route': (String key) {
    return WebRoute.getByKey(key)?.getUrl() ?? '';
  },
  'hasFlash': () {
    return RequestContext.rq.get('flash') != null;
  },
  'getFlashs': () {
    var flash = RequestContext.rq.getParam('flashs');
    RequestContext.rq.removeParam('flashs');
    return flash;
  },
  'updateUrlQuery': ([Object? updates]) {
    if (updates is String) {
      updates = jsonDecode(updates);
    }

    var newParams = <String, String>{};
    if (updates is Map) {
      for (var key in updates.keys) {
        newParams[key] = updates[key].toString();
      }
    }

    var queryParams = RequestContext.rq.uri.queryParameters
        .map((key, value) => MapEntry(key, value));

    var newUrl = Uri(
      queryParameters: {
        ...queryParams,
        ...newParams,
      },
    );

    return newUrl.toString();
  },
  'removeUrlQuery': (dynamic keys) {
    var queryParams = RequestContext.rq.uri.queryParameters
        .map((key, value) => MapEntry(key, value));

    for (var key in keys) {
      queryParams.remove(key);
    }

    var newUrl = Uri(
      queryParameters: queryParams,
    );

    return newUrl.toString();
  },
  'existUrlQuery': (dynamic keys) {
    for (var key in keys) {
      if (RequestContext.rq.uri.queryParameters.containsKey(key) &&
          RequestContext.rq.uri.queryParameters[key] != null &&
          RequestContext.rq.uri.queryParameters[key]!.isNotEmpty) {
        return true;
      }
    }
    return false;
  },
};

var localLayoutFilters = <String, Function>{
  'json': (Object? value) {
    return WaJson.jsonEncoder(value!);
  },
  'fix': (Object? value) {
    return value;
  },
  's': (Object? value) {
    return value == null ? '' : value.toString();
  },
  'if': (Object? value, Object? t, Object? f) {
    return value.toString().toBool ? t : f;
  },
};
