import 'dart:convert';
import 'dart:math';

import 'package:test/test.dart';
import 'package:webapp/src/tools/console.dart';
import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_server.dart';
import 'package:webapp/wa_tools.dart';
import 'package:http/http.dart' as http;

void main() async {
  WaServer server = WaServer(
    configs: WaConfigs(
      port: 8089,
      publicDir: 'public',
      languagePath: joinPaths([pathApp, '../example/lib/languages']),
      widgetsPath: '../example/lib/widgets',
      widgetsType: 'j2.html',
      dbConfig: WaDBConfig(
        enable: false,
      ),
    ),
  );

  Future<List<WebRoute>> routing(WebRequest rq) async {
    return [
      WebRoute(
        path: "/",
        rq: rq,
        index: () => rq.renderString(text: "TEST"),
        children: [
          WebRoute(
            path: 'checkurl',
            rq: rq,
            index: () {
              return rq.renderView(
                path: "<?= \$e.url('test') ?>",
                isFile: false,
              );
            },
          ),
          WebRoute(
            path: 'error',
            rq: rq,
            index: () {
              throw ("test error page");
            },
          ),
          WebRoute(
            path: 'widget',
            rq: rq,
            index: () {
              rq.addParam("testParam", "paramValue");
              return rq.renderView(
                path: "<?= \$e.url('test') ?>\n" +
                    "<?= testParam ?>\n" +
                    "<?= \$t('test.translate') ?>\n",
                isFile: false,
              );
            },
          ),
          WebRoute(
            path: "api/info",
            methods: RequestMethods.ONLY_GET,
            rq: rq,
            index: () {
              rq.addParam("data", "TEST");
              return rq.renderData(data: rq.getParams());
            },
          ),
          WebRoute(
            path: "api/post",
            methods: RequestMethods.ONLY_POST,
            rq: rq,
            index: () {
              return rq.renderData(data: {
                'sended': rq.getAllData(),
                'cookies': {
                  'sessionId': rq.getCookie('sessionId', safe: false),
                  'username': rq.getCookie('username', safe: false),
                },
              });
            },
          ),
          WebRoute(
            path: "api/auth/ok",
            methods: RequestMethods.ALL,
            rq: rq,
            auth: AuthController(rq, true),
            index: () {
              return rq.renderData(data: {
                'user': "TEST",
              });
            },
          ),
          WebRoute(
            path: "api/auth/failed",
            methods: RequestMethods.ALL,
            rq: rq,
            auth: AuthController(rq, false),
            index: () {
              return rq.renderData(data: {
                'user': "TEST",
              });
            },
          ),
        ],
      ),
    ];
  }

  server.addRouting(routing);
  var httpServer = await server.start().then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
    return value;
  });

  group("WebApp Server Test", () {
    test("Test 200", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}"),
      );
      expect(req.body, 'TEST', reason: "Response body should be 'TEST'");
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });

    test("Test API", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/api/info"),
      );
      var data = jsonDecode(req.body);

      expect(data['data'], 'TEST', reason: "Response body should be 'TEST'");
      expect(
        data['timestamp_start'].toString().toInt() > 0,
        true,
        reason: "timestamp should be > 0",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });

    test("Test API 404", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/api/notfound"),
      );
      var data = jsonDecode(req.body);

      expect(data['success'], false, reason: "Response body should be 'TEST'");
      expect(
        data['timestamp_start'].toString().toInt() > 0,
        true,
        reason: "timestamp should be > 0",
      );
      expect(req.statusCode, 404, reason: "Status code should be 404");
    });

    test("Test 404", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/notfound"),
      );
      var data = req.body;

      expect(
        data.contains("<html>"),
        true,
        reason: "Response body should be html",
      );
      expect(req.statusCode, 404, reason: "Status code should be 404");
    });

    test("Test Method", () async {
      var req = await http.post(
        Uri.parse("http://localhost:${httpServer.port}/notfound"),
      );
      var data = req.body;

      expect(
        data.contains("<html>"),
        true,
        reason: "Response body should be html",
      );
      expect(req.statusCode, 404, reason: "Status code should be 404");
    });

    test("Test POST data", () async {
      var random = Random().nextInt(100);
      var req = await http.post(
        Uri.parse("http://localhost:${httpServer.port}/api/post"),
        body: {
          'test': 'TEST',
          'random': '$random',
        },
      );
      var data = jsonDecode(req.body);
      expect(
        data['sended']['test'],
        'TEST',
        reason: "Sended data should be 'TEST'",
      );

      expect(
        data['sended']['random'].toString().toInt(),
        random,
        reason: "Sendend random should be $random",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });
  });

  test("Test Authenticator OK!", () async {
    var req = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/api/auth/ok"),
    );
    var data = jsonDecode(req.body);

    expect(
      data['user'],
      'TEST',
      reason: "Response body should be TEST",
    );
    expect(req.statusCode, 200, reason: "Status code should be 200");
  });

  test("Test Authenticator FAILED!", () async {
    var req = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/api/auth/failed"),
    );
    var data = jsonDecode(req.body);
    expect(
      data['success'],
      false,
      reason: "Response success should be false",
    );
    expect(req.statusCode, 404, reason: "Status code should be 404");
  });

  test("Test Cookies", () async {
    // Example cookies
    var cookies = 'sessionId=abc123; username=johndoe';

    var headers = {
      'Cookie': cookies,
    };
    var req = await http.post(
      Uri.parse("http://localhost:${httpServer.port}/api/post"),
      headers: headers,
    );

    var data = jsonDecode(req.body);
    var resCookies = data['cookies'];

    expect(
      resCookies['sessionId'],
      'abc123',
      reason: "Response success should be abc123",
    );
    expect(
      resCookies['username'],
      'johndoe',
      reason: "Response success should be johndoe",
    );
    expect(req.statusCode, 200, reason: "Status code should be 200");
  });

  test("check URL", () async {
    var req = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/checkurl"),
    );
    var data = req.body;
    expect(
      data,
      "http://localhost:${httpServer.port}/test",
      reason: "Response success should be /test",
    );
    expect(req.statusCode, 200, reason: "Status code should be 200");
  });

  test("check Error", () async {
    var req = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/error"),
    );
    var data = req.body;
    expect(
      data.contains("test error page"),
      true,
      reason: "Response success should contain 'test error page'",
    );
    expect(req.statusCode, 502, reason: "Status code should be 502");
  });

  test("check Widget events", () async {
    var req = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/widget"),
    );
    var data = req.body;

    expect(
      data,
      "http://localhost:${httpServer.port}/test\nparamValue\ntest.translate",
      reason: "Response success should contain 'test error page'",
    );
    expect(req.statusCode, 200, reason: "Status code should be 200");
  });
}

class AuthController extends WaAuthController<String> {
  bool testResult = false;
  WebRequest rq;
  AuthController(this.rq, this.testResult) : super(rq);

  @override
  Future<bool> auth() async {
    return testResult;
  }

  @override
  Future<bool> authApi() async {
    return testResult;
  }

  @override
  Future<
      ({
        bool success,
        String message,
        String user,
      })> checkLogin() async {
    return (
      success: testResult,
      message: 'Please login.',
      user: testResult ? 'TEST' : '',
    );
  }

  @override
  Future<bool> checkPermission() async {
    return true;
  }

  @override
  Future<String> loginPost() async {
    return rq.renderString(text: "TEST", status: 403);
  }

  @override
  Future<String> logout() async {
    return rq.renderString(text: "LOGOUT", status: 403);
  }

  @override
  Future<String> newUser() {
    throw UnimplementedError();
  }

  @override
  Future<String> register() {
    throw UnimplementedError();
  }

  @override
  void removeAuth() {}

  @override
  void updateAuth(String email, String password, user) {}
}
