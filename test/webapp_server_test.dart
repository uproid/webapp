import 'dart:convert';
import 'dart:math';
import 'package:test/test.dart';
import 'package:webapp/src/forms/advanced_form.dart';
import 'package:webapp/src/forms/form_validator.dart';
import 'package:webapp/src/tools/console.dart';
import 'package:webapp/src/views/htmler.dart';
import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_server.dart';
import 'package:webapp/wa_tools.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

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
        index: () => rq.renderString(text: "TEST"),
        children: [
          WebRoute(
            path: '/advanced_form',
            methods: RequestMethods.GET_ONLY,
            index: () async {
              var _ = TestAdvancedForm();
              return rq.renderDataParam();
            },
          ),
          WebRoute(
            path: '/advanced_form',
            methods: RequestMethods.POST_ONLY,
            index: () async {
              var form = TestAdvancedForm();
              await form.check();
              return rq.renderDataParam();
            },
          ),
          WebRoute(
            path: '/sse',
            index: () {
              var stream = Stream<SSE>.periodic(
                const Duration(
                  milliseconds: 100,
                ),
                (count) {
                  return SSE(
                    data: 'test $count',
                  );
                },
              ).take(10);
              return rq.renderSSE(stream);
            },
          ),
          WebRoute(
            path: 'htmler',
            index: () {
              rq.addParam('variable', 'VALUE');
              rq.addParam('list', ['item1', 'item2', 'item3', 'item4']);
              rq.addParam('condition', true);

              return rq.renderTag(
                  pretty: true,
                  tag: $Html(
                    attrs: {
                      'lang': 'en',
                    },
                    children: [
                      $Head(
                        children: [
                          $Meta(attrs: {'charset': 'UTF-8'}),
                          $Title(children: [$Text('Test Page')]),
                          $Meta(
                            attrs: {
                              'name': 'viewport',
                              'content':
                                  'width=device-width, initial-scale=1.0',
                            },
                          ),
                          $Title(children: [$Text('Test Page')]),
                        ],
                      ),
                      $Body(
                        children: [
                          $H1(children: [$Text('Hello, World!')]),
                          $P(children: [$Text('This is a test page.')]),
                          $A(
                            attrs: {
                              'href': 'https://example.com',
                              'id': 'example-link',
                            },
                            children: [
                              $Text('Click here to visit example.com')
                            ],
                          ),
                          $B(children: [
                            $JinjaVar('variable'),
                          ]),
                          JJ.$for(
                            item: 'item',
                            inList: 'list',
                            body: [
                              $Div(
                                children: [
                                  $Text('Item: '),
                                  $JinjaVar('item'),
                                ],
                                classes: [
                                  JJ.$shortIf(
                                    'condition',
                                    '"div-counter"',
                                    '"div-false"',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          JJ.$comment("TEST COMMENT"),
                          $Comment($Center(children: [
                            $Text('TEST CENTER COMMENT'),
                          ]))
                        ],
                      ),
                    ],
                  ));
            },
          ),
          WebRoute(
            path: 'checkurl',
            index: () {
              return rq.renderView(
                path: "<?= \$e.url('test') ?>",
                isFile: false,
              );
            },
          ),
          WebRoute(
            path: 'error',
            index: () {
              throw ("test error page");
            },
          ),
          WebRoute(
            path: 'debug_test',
            methods: RequestMethods.ALL,
            index: () {
              return rq.renderView(path: "<h1>Debug Test</h1>", isFile: false);
            },
          ),
          WebRoute(
            path: 'widget',
            index: () {
              rq.addParam("testParam", "paramValue");
              return rq.renderView(
                path: "<?= \$e.url('test') ?>\n"
                    "<?= testParam ?>\n"
                    "<?= \$t('test.translate') ?>\n",
                isFile: false,
              );
            },
          ),
          WebRoute(
            path: "api/info",
            methods: RequestMethods.ONLY_GET,
            index: () {
              rq.addParam("data", "TEST");
              return rq.renderData(data: rq.getParams());
            },
          ),
          WebRoute(
            path: "api/post",
            methods: RequestMethods.ONLY_POST,
            index: () {
              return rq.renderData(data: {
                'sended': rq.getAll(),
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
            auth: AuthController(true),
            index: () {
              return rq.renderData(data: {
                'user': "TEST",
              });
            },
          ),
          WebRoute(
            path: "api/auth/failed",
            methods: RequestMethods.ALL,
            auth: AuthController(false),
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
  var httpServer = await server.start([], false).then((value) {
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

  test('Test renderTag', () async {
    var req = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/htmler"),
    );
    var html = req.body;
    var document = parse(html);
    var htmlElement = document.getElementsByTagName('html').first;
    var aLink = document.getElementById('example-link');
    var p = document.getElementsByTagName('p').first;
    var h1 = document.getElementsByTagName('h1').first;
    var b = document.getElementsByTagName('b').first;
    var divs = document.getElementsByClassName('div-counter');

    expect(html, isNotNull);
    expect(
      htmlElement.attributes['lang'],
      equals('en'),
    );
    expect(
      aLink?.attributes['href'],
      equals('https://example.com'),
    );
    expect(
      aLink?.text,
      equals('Click here to visit example.com'),
    );
    expect(
      p.text,
      equals('This is a test page.'),
    );
    expect(
      h1.text,
      equals('Hello, World!'),
    );
    expect(
      b.text,
      equals('VALUE'),
    );
    expect(
      divs.length,
      equals(4),
    );
    expect(
      html,
      isNot(contains('TEST COMMENT')),
    );
    expect(
      html,
      contains('TEST CENTER COMMENT'),
    );
    expect(req.statusCode, 200, reason: "Status code should be 200");
  });

  test('Test SSE', () async {
    var req = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/sse"),
    );

    expect(req.statusCode, 200, reason: "Status code should be 200");
    expect(
      req.headers['content-type'],
      'text/event-stream; charset=utf-8',
      reason: "Content-Type should be text/event-stream",
    );

    var lines = req.body.split('\n');
    var dataLines = lines.where((line) => line.startsWith('data:')).toList();

    expect(dataLines.length, 11, reason: "Should receive 11 data lines");

    for (var i = 0; i < dataLines.length - 1; i++) {
      expect(
        dataLines[i],
        'data: test $i',
        reason: "Data line $i should be 'data: test $i'",
      );
    }
  });

  test('Test Advanced Form', () async {
    var reqGet = await http.get(
      Uri.parse("http://localhost:${httpServer.port}/advanced_form"),
      headers: {
        'Cookie': 'DARTSESSID=0f27deca10d6d3a19e9b5819c3f72eac;',
      },
    );
    var dataGet = jsonDecode(reqGet.body);

    var cookies = <String>[];
    if (reqGet.headers['set-cookie'] != null) {
      cookies.add(reqGet.headers['set-cookie']!);
    }

    var reqPost = await http.post(
      Uri.parse("http://localhost:${httpServer.port}/advanced_form"),
      headers: {
        'Cookie': cookies.join('; '),
      },
      body: {
        'name': 'John Doe',
        'age': '30',
        'email': 'john.doe@example.com',
        'token': dataGet['test_form']['token']['value'],
      },
    );
    var dataPost = jsonDecode(reqPost.body);

    var reqPost2 = await http.post(
      Uri.parse("http://localhost:${httpServer.port}/advanced_form"),
      headers: {
        'Cookie': cookies.join('; '),
      },
      body: {
        'name': 'a',
        'age': '-1',
        'email': 'john.doe@example',
        'token': '${dataGet['test_form']['token']['value']}_fake',
      },
    );
    var dataPost2 = jsonDecode(reqPost2.body);

    expect(reqPost.statusCode, 200, reason: "Status code should be 200");
    expect(
      dataPost['test_form']['success'],
      isTrue,
      reason: "Form submission should be successful",
    );
    expect(
      dataPost2['test_form']['success'],
      isFalse,
      reason: "Form submission should fail with invalid token",
    );
    expect(
      dataPost2['test_form']['token']['success'],
      isFalse,
      reason: "Token field should have errors",
    );
    expect(
      dataPost2['test_form']['name']['success'],
      isFalse,
      reason: "Name field should have errors",
    );
    expect(
      dataPost2['test_form']['age']['success'],
      isFalse,
      reason: "Age field should have errors",
    );
    expect(
      dataPost2['test_form']['email']['success'],
      isFalse,
      reason: "Email field should have errors",
    );
  });
}

class AuthController extends WaAuthController<String> {
  bool testResult = false;
  AuthController(this.testResult);

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

class TestAdvancedForm extends AdvancedForm {
  @override
  String get name => 'test_form';

  @override
  List<Field> fields() {
    return [
      csrf(),
      Field('name', validators: [
        FieldValidator.requiredField(),
        FieldValidator.fieldLength(min: 3),
      ]),
      Field(
        'age',
        validators: [
          FieldValidator.isNumberField(
            max: 100,
            min: 1,
            isRequired: false,
          ),
        ],
      ),
      Field('email', validators: [
        FieldValidator.requiredField(),
        FieldValidator.isEmailField(),
      ]),
    ];
  }
}
