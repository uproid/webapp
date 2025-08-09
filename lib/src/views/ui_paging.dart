import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_tools.dart';
import 'package:webapp/src/views/wa_views.dart';

/// A class that handles pagination logic and generates view parameters for rendering.
///
/// The [UIPaging] class is used to manage pagination, including calculating the
/// current page, the range of pages to display, and handling query parameters.
/// It extends [WaView] to integrate with the application's view rendering system.
class UIPaging extends WaView {
  /// The current page number.
  int page;

  /// The total number of items.
  int total;

  /// The number of items per page. Defaults to 20.
  int pageSize;

  /// The number of pages displayed on either side of the current page.
  int widthSide;

  /// The query parameter used to identify the page number in URLs. Defaults to 'page'.
  String profix;

  /// Additional query parameters to include in the pagination URLs.
  Map<String, String> otherQuery;

  /// Whether to use query parameters from the request object.
  bool useRequsetQueries;

  /// The column or field used for ordering the items.
  String orderBy;

  /// Whether the ordering should be in reverse (descending).
  bool orderReverse;

  /// Calculates the starting index for the current page based on [page] and [pageSize].
  ///
  /// The start index is adjusted if the page exceeds the total number of items.
  int get start {
    var start = (page - 1) * pageSize;
    if (start >= total) {
      start =
          total % pageSize == 0 ? total - pageSize : total - (total % pageSize);
    }
    return start;
  }

  /// Creates a new [UIPaging] instance.
  ///
  /// The constructor requires the current request object [rq], a [widget] identifier,
  /// and the [page] and [total] number of items. Optional parameters include:
  /// - [pageSize]: The number of items per page (default is 20).
  /// - [profix]: The page query parameter name (default is 'page').
  /// - [otherQuery]: Additional query parameters.
  /// - [widthSide]: The number of pages to show on each side of the current page (default is 2).
  /// - [useRequsetQueries]: Whether to include request query parameters.
  /// - [orderBy]: The field used for ordering.
  /// - [orderReverse]: Whether the order is reversed (descending).
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

  /// A factory constructor to create [UIPaging] from a request object [rq].
  ///
  /// This factory method extracts relevant pagination information from the request
  /// and provides default values for optional parameters:
  /// - [total]: The total number of items.
  /// - [profix]: The page query parameter name (default is 'page').
  /// - [widget]: The widget identifier (default is 'dashboard/theme/ui/paging').
  /// - [otherQuery]: Additional query parameters.
  /// - [pageSize]: The number of items per page (default is 5).
  /// - [orderByDef]: The default field for ordering.
  /// - [orderReverseDef]: The default ordering direction.
  /// - [pageDef]: The default page number (default is 1).
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

  /// Generates and returns a map of data for rendering the pagination UI.
  ///
  /// The method calculates the page range to display, handles edge cases where
  /// the page number is out of bounds, and includes additional query parameters.
  ///
  /// The returned map includes:
  /// - `total`: The total number of items.
  /// - `count`: The total number of pages.
  /// - `page`: The current page.
  /// - `pageSize`: The number of items per page.
  /// - `toEnd`: The index of the last item on the current page.
  /// - `profix`: The page query parameter name.
  /// - `rangeTo`: The last page in the displayed range.
  /// - `rangeFrom`: The first page in the displayed range.
  /// - `disableFirst`: Whether the "first page" button should be disabled.
  /// - `disableLast`: Whether the "last page" button should be disabled.
  /// - `other`: Additional query parameters.
  /// - `orderBy`: The field used for ordering.
  /// - `orderReverse`: Whether the order is reversed.
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
