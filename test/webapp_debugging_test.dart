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
      enableLocalDebugger: true,
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
            path: 'debug_test',
            rq: rq,
            methods: RequestMethods.ALL,
            index: () {
              return rq.renderView(path: "<h1>Debug Test</h1>", isFile: false);
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
        ],
      ),
    ];
  }

  server.addRouting(routing);
  var httpServer = await server.start([], false).then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
    return value;
  });

  group("test debugger", () {
    test("checking Debugger1", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/debugger/console.js"),
      );

      expect(
        req.statusCode,
        200,
        reason:
            "Response success should contain 'console.js' it used for debugging",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });

    test("checking Debugger2", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/debug_test/"),
      );
      var content = req.body;
      expect(
        content.contains("<script href='/debugger/console.js'></script>"),
        true,
        reason:
            "Response success should contain '<script>' it used for debugging",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });

    test("checking Debugger3", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/api/info"),
      );
      var content = req.body;
      print(content);
      expect(
        content.contains("<script href='/debugger/console.js'></script>"),
        false,
        reason: "debugger used only on HTML pages",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });
  });
}
