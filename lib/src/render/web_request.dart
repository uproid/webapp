// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:webapp/model_less.dart';
import 'package:webapp/src/render/asset_manager.dart';
import 'package:webapp/src/render/authorization.dart';
import 'package:webapp/src/router/request_methods.dart';
import 'package:webapp/src/router/web_route.dart';
import 'package:webapp/src/tools/console.dart';
import 'package:webapp/src/tools/convertor/query_string.dart';
import 'package:webapp/src/tools/convertor/safe_string.dart';
import 'package:webapp/src/tools/convertor/serializable/value_converter.dart/json_value.dart';
import 'package:webapp/src/tools/convertor/string_validator.dart';
import 'package:webapp/src/tools/convertor/translate_string.dart';
import 'package:webapp/src/tools/path.dart';
import 'package:webapp/src/widgets/widget_error.dart';
import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:mime/mime.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:webapp/dw_server.dart';

class WebRequest {
  final HttpRequest _rq;
  late final AssetManager assetManager = AssetManager(this);
  var isClosed = false;

  static Map<String, Object?> _setting = {};
  WebRoute? route;
  WebRequest(this._rq);
  HttpRequest get httpRequest => _rq;

  HttpSession get session => _rq.session;
  List<Cookie> get cookies => _rq.cookies;
  HttpRequest get stream => _rq;
  Uri get uri => _rq.uri;
  HttpResponse get response => _rq.response;
  String get method => _rq.method;
  HttpHeaders get headers => _rq.headers;

  setSetting(Map<String, Object?> setting) {
    ///To change theme when Cookie of theme is seted.
    var theme = getCookie(
      'theme',
      def: (setting['theme'] ?? 'light').toString(),
      safe: false,
    );
    if (['light', 'dark'].contains(theme)) {
      setting['theme'] = theme;
    }

    _setting = {
      ...setting,
    };
  }

  Future<WebRequest> init() async {
    _rq.response.headers.add('Access-Control-Allow-Origin', "*");
    _rq.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET,HEAD,OPTIONS,POST,PUT,DELETE',
    );
    _rq.response.headers.add('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept, x-client-key, x-client-token, x-client-secret, Authorization');
    _rq.response.headers.add('Access-Control-Allow-Credentials', 'true');

    await parseData();
    return this;
  }

  Map<String, dynamic> _dataRequest = {
    'POST': {},
    'GET': {},
    'CONTENT': '',
    'FILE': '',
  };

  void changeLanguege(String ln) {
    addCookie('language', ln, safe: false);
    addSession('language', ln);
  }

  String getLanguage() {
    var ln = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    if (ln.isNotEmpty && DwServer.config.languages.contains(ln)) {
      changeLanguege(ln);
      return ln;
    }

    if (isApiEndpoint && hasData('lang')) {
      return data('lang', def: 'en');
    }

    ln = getCookie(
      'language',
      safe: false,
      def: getSession(
        'language',
        def: _setting['language'] ?? 'en',
      ).toString(),
    );

    return ln.trim().toLowerCase();
  }

  Future writeAndClose(String layout) async {
    if (isClosed) return;

    layout = onClose(layout);
    response.write(layout);
    await _close();
  }

  String onClose(String layout) {
    // 1. Replace assets values.
    if (dataJsId.isNotEmpty) {
      layout = layout.replaceFirst(dataJsId, assetManager.getDataJs());
    }
    // 2. Reolace assets url Js, Css
    if (cssRenderId.isNotEmpty) {
      layout = layout.replaceFirst(cssRenderId, assetManager.getCssUI());
    }
    if (jsRenderId.isNotEmpty) {
      layout = layout.replaceAll(jsRenderId, assetManager.getJsUI());
    }
    return layout;
  }

  Future _close() async {
    if (!isClosed) {
      isClosed = true;
      await _rq.response.close();
    }
  }

  Future<Map> parseData() async {
    Map<String, dynamic> post = {};
    Map<String, dynamic> get = {};
    Map<String, dynamic> file = {};
    String content = "";

    // For GET
    var params = _rq.uri.queryParameters;
    get.addAll(params);
    // For POST or PUT
    if (method == RequestMethods.POST || method == RequestMethods.PUT) {
      // Form Forms
      if (headers.contentType
          .toString()
          .toLowerCase()
          .contains("application/x-www-form-urlencoded")) {
        try {
          content = await utf8.decoder.bind(stream).join();
          var body = QueryString.parse(content);
          post.addAll(body);
        } catch (e) {
          Console.e(e);
        }
      } else if (headers.contentType
          .toString()
          .toLowerCase()
          .contains("multipart/form-data")) {
        var data = await getHeaderFormData();
        post.addAll(data['fields']);
        file.addAll(data['files']);
      } else if (headers.contentType
          .toString()
          .toLowerCase()
          .contains("application/json")) {
        try {
          content = await utf8.decoder.bind(stream).join();
          var data = jsonDecode(content);
          post.addAll(data);
        } catch (e) {
          Console.e(e);
        }
      } else {
        try {
          var bodyBytes = await stream
              .fold<List<int>>([], (bytes, chunk) => bytes..addAll(chunk));
          content = String.fromCharCodes(bodyBytes);
        } catch (e) {
          Console.e(e);
        }
      }
    }
    _dataRequest = {
      'POST': post,
      'GET': get,
      'FILE': file,
      'CONTENT': content,
    };

    return _dataRequest;
  }

  Map getAllData() {
    var map = {
      ..._dataRequest['GET']!,
      ..._dataRequest['POST'],
      'POST': _dataRequest['POST'],
      'GET': _dataRequest['GET'],
      'FILE': _dataRequest['FILE'],
    };
    return map;
  }

  String data(String key, {String def = ''}) {
    var map = getAllData();
    ModelLess modelLess = ModelLess.fromMap(map);

    String res = modelLess.get<String>(key, def: def);
    return res.removeScripts();
  }

  dynamic dataObject(String key, {dynamic def}) {
    var map = getAllData();
    return map[key] ?? def;
  }

  T dataType<T>(String key, {T? def}) {
    var map = getAllData();
    T res = map[key] ?? def;
    return res;
  }

  dynamic getFile(String key) {
    var map = getAllData();
    return map['FILE'] != null ? map['FILE'][key] : null;
  }

  String operator [](String key) {
    return data(key);
  }

  bool hasData(String key) => getAllData().containsKey(key);
  bool hasDataValue(String key) =>
      getAllData().containsKey(key) && this[key].isNotEmpty;

  T get<T>(String key, {T? def}) {
    switch (T) {
      case List:
        var res = dataObject(key, def: def);
        if (res is List) {
          return res as T;
        }
        if (def != null) return def;
        return [] as T;
      case num:
        var res = (num.tryParse(data(key)) ?? -1);
        if (def != null && res == -1) return def;
        return res as T;
      case int:
        var res = (int.tryParse(data(key)) ?? -1);
        if (def != null && res == -1) return def;
        return res as T;
      case bool:
        return data(key).toBool as T;
      case String:
        var res = data(key).toString();
        if (res.isEmpty && def != null) return def;
        return res as T;
      default:
        return data(key) as T;
    }
  }

  Future<String> renderError(
    int status, {
    Map<String, Object?> params = const {},
    String message = '',
    bool toData = false,
  }) {
    if (message.isNotEmpty) {
      addParam('error', message);
    } else if (toData && !hasParam('success')) {
      if (!hasParam('message')) {
        addParam('message', status == 404 ? 'error.notfound' : 'error.$status');
      }
      addParam('success', false);
    }

    if (Console.isDebug) {
      addParams(params);
    }

    addParam('status', status);

    return renderView(
      path: ErrorWidget().layout,
      status: status,
      isFile: false,
      toData: toData,
    );
  }

  final ModelLess _params = ModelLess(fields: {
    'timestamp_start': DateTime.now().millisecondsSinceEpoch,
  });

  Object? getParam(String key, {Object? def}) {
    return _params[key] ?? def;
  }

  bool hasParam(String key) {
    return _params.fields.keys.contains(key);
  }

  Map<String, dynamic> getParams() {
    return _params.fields;
  }

  final _validator = <String, Object?>{};
  Map<String, Object?> getValidator() {
    return _validator;
  }

  void addValidator(String formName, Map<String, dynamic> validator) {
    _validator[formName] = validator;
  }

  WebRequest addParams(Map<String, Object?> params) {
    params.forEach((key, value) {
      _params[key] = value;
    });
    return this;
  }

  WebRequest addParam(String key, Object? param) {
    _params[key] = param;
    return this;
  }

  WebRequest removeParam(String key) {
    _params.remove(key);
    return this;
  }

  /// after this function everything will be stop and send to client
  Future<String> renderView({
    required String path,
    int status = 200,
    bool isFile = true,
    bool toData = false,
    Map<String, dynamic> data = const {},
  }) async {
    if (isClosed) return '';

    if (toData) {
      return renderDataParam(status: status, data: data);
    }

    try {
      response.statusCode = status;
      response.headers.contentType = ContentType.html;
    } catch (e) {
      Console.i(e);
    }
    var renderString = await render(path: path, isFile: isFile);
    await writeAndClose(renderString);
    return renderString;
  }

  /// Use render() to load widgets, without stoping
  Future<String> render({
    required String path,
    Map<String, Object?> viewParams = const {},
    bool isFile = true,
    bool toData = false,
    int status = 200,
  }) async {
    if (isClosed) return '';

    if (toData) {
      return renderDataParam(status: status, data: viewParams);
    }

    if (isFile) {
      File file = File(joinPaths([
        DwServer.config.widgetsPath,
        "$path.${DwServer.config.widgetsType}",
      ]));

      if (!file.existsSync()) {
        if (DwServer.config.isLocalDebug) {
          return "The path: ${file.path} is not correct!";
        } else {
          return "The path: ${file.uri.pathSegments.last} is not correct!";
        }
      }
    }

    var env = Environment(
        globals: getGlobalEvents(),
        autoReload: false,
        loader: FileSystemLoader(paths: <String>[DwServer.config.widgetsPath]),
        leftStripBlocks: false,
        trimBlocks: false,
        blockStart: DwServer.config.blockStart,
        blockEnd: DwServer.config.blockEnd,
        variableStart: DwServer.config.variableStart,
        variableEnd: DwServer.config.variableEnd,
        commentStart: DwServer.config.commentStart,
        commentEnd: DwServer.config.commentEnd,
        filters: {
          'dateFormat': (DateTime dt, String format) {
            return DateFormat(format).format(dt);
          },
        },
        getAttribute: (String key, dynamic object) {
          try {
            if (object is TString) {
              return object.write(this);
            }
            if (object is String && key == 'tr') {
              return object.tr.write(this);
            }
            if (object is Cookie) {
              return key == 'name' ? object.name : object.value;
            }

            if (object[key] != null) {
              if (object[key] is ObjectId) {
                (object[key] as ObjectId).oid;
              }
            }
            return object[key];
          } on NoSuchMethodError {
            Console.e({
              'error': {
                'object': object,
                'key': key,
                'error': 'The key "$key" on "$object" not found',
              }
            });

            if (object == null) {
              if (DwServer.config.isLocalDebug) {
                return 'The key "$key" on "$object" not found';
              } else {
                return null;
              }
            }

            return null;
          } catch (e) {
            Console.e({
              'error': {
                'object': object,
                'key': key,
                'error': e,
              }
            });
            return null;
          }
        });
    var params = getParams();
    params.addAll(viewParams);
    Template template;
    if (isFile) {
      template = env.getTemplate(File(
        joinPaths([
          DwServer.config.widgetsPath,
          "$path.${DwServer.config.widgetsType}",
        ]),
      ).path);
    } else {
      template = env.fromString(path);
    }
    var renderString = template.render(params);
    return renderString;
  }

  /// currently it just support the Basic Authentication
  /// You can develop the `Authorization` class.
  Authorization get authorization {
    var authString = headers.value(HttpHeaders.authorizationHeader) ?? '';
    return Authorization.parse(authString);
  }

  Future<String> renderDataParam({
    int status = 200,
    Map<String, Object?> data = const {},
  }) {
    return renderData(
      data: {
        ...getParams(),
        ...getValidator(),
        ...data,
      },
      status: status,
    );
  }

  Future<String> renderListData({
    required List<Map<String, Object?>> data,
    int status = 200,
  }) async {
    try {
      try {
        response.statusCode = status;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      var renderString = DwJson.jsonEncoder(data, rq: this);
      await writeAndClose(renderString);
      return renderString;
    } catch (e) {
      try {
        response.statusCode = 502;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      return jsonEncode({
        'status': 502,
        'error': e,
      });
    }
  }

  Future<String> renderData({
    required Map<String, Object?> data,
    int status = 200,
  }) async {
    try {
      try {
        response.statusCode = status;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      var renderString = DwJson.jsonEncoder(data, rq: this);
      await writeAndClose(renderString);
      return renderString;
    } catch (e) {
      try {
        response.statusCode = 502;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      return jsonEncode({
        'status': 502,
        'error': e,
      });
    }
  }

  String renderSocket() => 'Socket is requested!';

  Future<String> renderString({
    required String text,
    int status = 200,
    ContentType? contentType,
  }) async {
    try {
      try {
        response.statusCode = status;
        response.headers.contentType = contentType ?? ContentType.text;
      } catch (e) {
        renderError(502, params: {'error': e});
      }
      await writeAndClose(text);
      return text;
    } catch (e) {
      renderError(502, params: {'error': e});
      return 'console.log("$e");';
    }
  }

  Future<String> renderHtml({
    required String html,
    int status = 200,
  }) async {
    return renderString(
      text: html,
      status: status,
      contentType: ContentType.html,
    );
  }

  Future<String> redirectUri(
    Uri uri, {
    int status = HttpStatus.movedTemporarily,
    bool checkApiPath = true,
  }) {
    return redirect(
      uri.toString(),
      status: status,
      checkApiPath: checkApiPath,
    );
  }

  Future<String> redirectNextUri(
    Uri uri, {
    int status = HttpStatus.movedTemporarily,
    bool checkApiPath = true,
  }) async {
    if (isClosed) {
      return '';
    }
    isClosed = true;
    await response.redirect(
      uri,
      status: status,
    );
    return "Wait to redirect!?";
  }

  Future<String> redirect(
    String path, {
    int status = HttpStatus.movedTemporarily,
    bool checkApiPath = true,
  }) async {
    if (isClosed) {
      return '';
    }
    isClosed = true;

    if (path.toLowerCase().startsWith("http") ||
        path.toLowerCase().startsWith("https")) {
      await response.redirect(
        Uri.parse(path),
        status: status,
      );
      return "Wait to redirect!?";
    }

    if (checkApiPath && isApiEndpoint) {
      path = joinPaths(['/api', path]);
    }

    await response.redirect(
      Uri.parse(path),
      status: status,
    );
    return "Wait to redirect!?";
  }

  Future<Map> getHeaderFormData() async {
    final fields = <String, String>{};
    final files = <String, List<int>>{};
    final contentType = _rq.headers.contentType;
    if (contentType?.mimeType == 'multipart/form-data') {
      final transformer =
          MimeMultipartTransformer(contentType!.parameters['boundary']!);

      final parts = await transformer.bind(_rq).toList();

      await Future.forEach(parts, (part) async {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition != null) {
          final nameMatch =
              RegExp(r'name="(.+?)"').firstMatch(contentDisposition);
          final filenameMatch =
              RegExp(r'filename="(.+?)"').firstMatch(contentDisposition);
          if (filenameMatch != null) {
            //final filename = filenameMatch.group(1);
            final fileBytes = await part
                .fold<List<int>>([], (bytes, data) => bytes..addAll(data));
            files[nameMatch!.group(1)!] = fileBytes;
          } else {
            final value = await utf8.decodeStream(part);
            fields[nameMatch!.group(1)!] = value;
          }
        }
      });
    }

    return {
      'fields': fields,
      'files': files,
    };
  }

  String jsRenderId = '';
  String cssRenderId = '';
  String dataJsId = '';
  static final localEvents = <String, Object>{
    'test': (a) => "You passed '$a'",
  };

  Map<String, Object?> getGlobalEvents() {
    Map<String, Object?> params = {};
    params['isLocalDebug'] = DwServer.config.isLocalDebug;
    params['assets'] = {
      'js': () {
        if (jsRenderId.isNotEmpty) return jsRenderId;
        jsRenderId = "<#DART-SERVER#>JS<#DART-SERVER#>";
        return jsRenderId;
      },
      'css': () {
        if (cssRenderId.isNotEmpty) return cssRenderId;
        cssRenderId = "<#DART-SERVER#>CSS<#DART-SERVER#>";
        return cssRenderId;
      },
      'dataJs': () {
        if (dataJsId.isNotEmpty) return dataJsId;
        dataJsId = "<#DART-SERVER#>JS-DATA<#DART-SERVER#>";
        return dataJsId;
        //assetManager.getDataJs();
      },
    };

    params['render'] = () => 'TODO';
    params['data'] = getAllData();
    params['session'] = getAllSession();
    params['param'] = (String path) {
      return _params.getByPathString(path, def: '');
    };
    params['validator'] = (String path) {
      return getValidator().navigation<Object>(
        path: path,
        def: '',
      );
    };
    var events = {
      'route': route == null ? '/' : route!.getPathRender(),
      'uri': Uri.encodeComponent(_rq.requestedUri.toString()),
      'path': Uri.encodeComponent(_rq.requestedUri.path),
      'pathString': _rq.requestedUri.path,
      'isPath': (String path) {
        return _rq.requestedUri.path == path;
      },
      'endpoint': endpoint,
      'url': (String path) {
        return url(path);
      },
      'urlToLanguage': (String language) {
        if (_rq.requestedUri.pathSegments.isNotEmpty &&
            _rq.requestedUri.pathSegments[0] == language) {
          return url(_rq.requestedUri.path);
        } else if (_rq.requestedUri.pathSegments.isNotEmpty &&
            _rq.requestedUri.pathSegments[0] == getLanguage()) {
          var paths = _rq.requestedUri.pathSegments.sublist(1);
          return url('/$language/${paths.join('/')}');
        }
        return url('/$language${_rq.requestedUri.path}');
      },
      'urlParam': (String path, Map<String, String> params) {
        return url(path, params: params);
      },
      'getCookie': (String key, [String def = '']) {
        return getCookie(key, def: def);
      },
      'ln': getLanguage(),
      'dir': 'language.${getLanguage()}_dir'.tr.write(this),
      'langs': () {
        var langs = DwServer.appLanguages.keys;
        var result = [];

        for (var lang in langs) {
          result.add({
            'code': lang,
            'label': 'language.${lang}_label'.tr.write(this),
            'contry': 'language.${lang}_contry'.tr.write(this),
          });
        }

        return result;
      },
      'pageTitle': route != null && route!.title.isNotEmpty
          ? route!.title
          : 'pages.title'.tr.write(this),
      'setting': _setting,
      'formChecker': ([String? name]) => formChecker(name: name),
    };

    params['\$e'] = LMap(events, def: null);
    params['\$l'] = LMap(localEvents, def: null);
    params['\$t'] = (String text, [Object? params]) {
      if (params == null) {
        return text.tr.write(this);
      } else {
        // if (params is Map) {
        //   return text.trParam(params);
        // } else if (params is List) {
        //   return text.trList(params);
        // }
      }

      return text.tr.write(this);
    };
    addParam('timestamp_end', DateTime.now().millisecondsSinceEpoch);
    var duration = (getParam('timestamp_end', def: 0) as int) -
        (getParam('timestamp_start', def: 0) as int);
    addParam('duration', duration);
    var lmap = LMap(params, def: null);

    params['\$'] = lmap;
    return params;
  }

  Object getAllSession() {
    var res = {
      'session': session,
      'cookies': cookies,
    };

    return res;
  }

  String get endpoint => pathNorm(_rq.requestedUri.path, normSlashs: true);

  /// Checked the endpoint starts with 'api/' or not
  bool get isApiEndpoint => endpoint.startsWith('api/');

  ///Use this function for sequrity values
  String getCookie(
    String key, {
    String def = '',
    bool safe = true,
  }) {
    for (var cookie in _rq.cookies) {
      if (cookie.name == key) {
        if (!safe) {
          return cookie.value;
        } else {
          return cookie.value.fromSafe(DwServer.config.cookiePassword);
        }
      }
    }

    return def;
  }

  Object getSession(String key, {Object? def = ''}) {
    return session[key] ?? def;
  }

  addSession(String key, Object value) {
    session[key] = value;
  }

  ///Use this function for sequrity values
  addCookie(
    String key,
    String value, {
    Duration? duration,
    bool safe = true,
  }) {
    cookies.removeWhere((element) => element.name == key);
    value = safe ? value.toSafe(DwServer.config.cookiePassword) : value;
    var cookie = Cookie(key, value);
    cookie.maxAge = duration?.inSeconds;
    cookie.path = '/';
    cookie.secure = false;
    cookie.httpOnly = false;
    _rq.response.cookies.add(cookie);
    _rq.cookies.add(cookie);
  }

  void removeCookie(String key) {
    addCookie(key, '', duration: Duration(days: -1, seconds: -1));
    cookies.removeWhere((element) => element.name == key);
  }

  String url(String subPath, {Map<String, String>? params}) {
    var pathRequest = _rq.requestedUri.origin;
    var uri = Uri.parse(pathRequest);
    uri = uri.resolve(subPath);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    /// Force to HTTPS for all URLs in Deployment
    /// When the app is localhost app does not load from HTTPS
    if (!DwServer.config.isLocalDebug) {
      uri = uri.replace(scheme: 'https');
    }
    var url = uri.toString();
    return url;
  }

  AssetManager addAsset(Asset asset) => assetManager.addAsset(asset);

  AssetManager addAssets(List<Asset> assets) => assetManager.addAssets(assets);

  List<Asset> getAssets() => assetManager.includes;

  String generateRandomString([int length = 8]) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final charList =
        List.generate(length, (index) => chars[random.nextInt(chars.length)]);
    return charList.join('');
  }

  String formChecker({String? name, bool inputHtml = true}) {
    name = name ?? 'formChecker';
    final key = generateRandomString();
    var res = '<input type="hidden" name="$name" value="$key" />';
    addSession(
      name,
      {
        'key': key,
        'time': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return inputHtml ? res : key;
  }

  bool checkForm([String? name]) {
    name = name ?? 'formChecker';
    final dataField = data(name, def: 'unknown');
    if (dataField != 'unknown') {
      Map dataSession = getSession(name, def: 'unknown2') as Map;
      if (dataField == dataSession['key']) {
        int duration = DateTime.now().millisecondsSinceEpoch -
            (dataSession['time'] as int);
        if (duration / 1000 < 600) {
          return true;
        }
      }
    }
    return false;
  }

  /// return value string of IP address that application received from Nginx.
  /// pay atention that you have the headers of IP address in your Nginx configuration.
  /// two headers that wee need are: X-Real-IP, X-Forwarded-For
  String getIP() {
    String? ip = headers.value('X-Real-IP');

    if (ip != null) {
      return ip;
    }

    ip = headers.value('X-Forwarded-For');

    if (ip != null) {
      return ip;
    }

    return response.connectionInfo?.remoteAddress.address ?? '127.0.0.1';
  }
}
