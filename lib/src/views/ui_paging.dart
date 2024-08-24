import 'package:webapp/dw_route.dart';
import 'package:webapp/dw_tools.dart';
import 'package:webapp/src/views/dw_views.dart';

class UIPaging extends DwView {
  int page;
  int total;
  int pageSize;
  int widthSide;
  String profix;
  Map<String, String> otherQuery;
  bool useRequsetQueries;
  String orderBy;
  bool orderReverse;

  int get start {
    var start = (page - 1) * pageSize;
    if (start >= total) {
      start =
          total % pageSize == 0 ? total - pageSize : total - (total % pageSize);
    }
    return start;
  }

  UIPaging({
    required super.rq,
    required super.widget,
    super.params,

    ///
    required this.page,
    required this.total,
    this.pageSize = 20,
    this.profix = 'page',
    this.otherQuery = const <String, String>{},
    this.widthSide = 2,
    this.useRequsetQueries = false,

    ///
    this.orderBy = '',
    this.orderReverse = false,
  });

  factory UIPaging.fromRequest(
    WebRequest rq, {
    required int total,
    String profix = 'page',
    String widget = 'dashboard/theme/ui/paging',
    Map<String, String> otherQuery = const {},
    int pageSize = 5,
    String orderByDef = '',
    bool orderReverseDef = false,
    int pageDef = 1,
  }) {
    var page = rq.get<int>(profix, def: pageDef);
    var pageSizeFix = rq.get<int>('pageSize', def: pageSize);
    var orderBy = rq.get<String>('orderBy', def: orderByDef);
    var orderReverse = rq.get<bool>('orderReverse', def: orderReverseDef);

    return UIPaging(
      rq: rq,
      widget: widget,
      page: page,
      total: total,
      pageSize: pageSizeFix,
      orderBy: orderBy,
      orderReverse: orderReverse,
      profix: profix,
      otherQuery: otherQuery,
    );
  }

  @override
  Future<Map<String, Object?>> renderData() async {
    page = page < 1 ? 1 : page;
    var count = (total / pageSize).ceil();
    if (page > count) {
      page = count;
    }
    var toEnd = page * pageSize;
    toEnd = (toEnd > total) ? total : toEnd;
    var rangeFrom = page - widthSide;
    var rangeTo = page + widthSide;
    if (page <= widthSide) {
      rangeTo += widthSide - page + 1;
    }

    if (count - widthSide < page) {
      rangeFrom -= widthSide - (count - page);
    }

    if (useRequsetQueries) {
      rq.uri.queryParameters.forEach((key, value) {
        if (key != profix && !otherQuery.containsKey(key)) {
          otherQuery[key] = value;
        }
      });
    }

    var other = otherQuery.joinMap('=', '&');

    var viewParams = {
      'total': total,
      'count': count,
      'page': page,
      'pageSize': pageSize,
      'toEnd': toEnd,
      'profix': profix,
      'rangeTo': rangeTo,
      'rangeFrom': rangeFrom,
      'disableFirst': page - 1 <= 0,
      'disableLast': page - count >= 0,
      'other': other.isEmpty ? "" : "&$other",
      'orderBy': orderBy,
      'orderReverse': orderReverse,
    };

    return viewParams;
  }
}
