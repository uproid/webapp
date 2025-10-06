import '../controllers/htmler_controller.dart';
import '../configs/setting.dart';
import '../app.dart';
import '../controllers/api_document.dart';
import 'package:webapp/wa_route.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

Future<List<WebRoute>> getWebRoute(WebRequest rq) async {
  final homeController = HomeController(rq);
  final htmlerController = HtmlerController(rq);
  final authController = AuthController(rq, homeController);
  final includeController = IncludeJsController(rq);
  final apiController = WaApiController(
    title: "API Documentation",
    rq,
    server: server,
  );

  var paths = [
    WebRoute(
      path: 'sse',
      methods: RequestMethods.ALL,
      index: homeController.sseExample,
    ),
    WebRoute(
      path: 'api/docs',
      index: () {
        return apiController.index(showPublic: true);
      },
    ),
    WebRoute(
      path: 'swagger',
      controller: WaSwaggerController(rq, rq.url('api/docs')),
    ),
    WebRoute(
      path: 'ws',
      methods: RequestMethods.ALL,
      index: homeController.socket,
    ),
    WebRoute(
      path: 'app/includes.js',
      methods: RequestMethods.ALL,
      index: includeController.index,
    ),
    WebRoute(
      path: 'example',
      index: () => rq.redirect('/'),
      children: [
        WebRoute(
          path: 'host',
          hosts: ['localhost'],
          ports: [80, 8085],
          index: () => rq.renderString(text: 'Localhost'),
          methods: RequestMethods.ALL,
        ),
        WebRoute(
          path: 'host',
          ports: [80, 8085],
          hosts: ['127.0.0.1'],
          index: () => rq.renderString(text: '127.0.0.1'),
          methods: RequestMethods.ALL,
        ),
        WebRoute(
          path: 'form',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleForm,
        ),
        WebRoute(
          path: 'form',
          methods: RequestMethods.ONLY_POST,
          index: authController.loginPost,
        ),
        WebRoute(
          path: 'panel',
          methods: RequestMethods.ALL,
          auth: authController,
          index: homeController.exampleAuth,
          permissions: ['admin'],
        ),
        WebRoute(
          path: 'language',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleLanguage,
        ),
        WebRoute(
          path: 'cookie',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleCookie,
        ),
        WebRoute(
          path: 'cookie',
          methods: RequestMethods.ONLY_POST,
          index: homeController.exampleAddCookie,
        ),
        WebRoute(
          path: 'cookie',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleAddCookie,
        ),
        WebRoute(
          path: 'route',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleRoute,
        ),
        WebRoute(
          path: 'socket',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleSocket,
        ),
        WebRoute(
          path: 'email',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleEmail,
        ),
        WebRoute(
          path: 'email',
          methods: RequestMethods.ONLY_POST,
          index: homeController.exampleEmailSend,
        ),
        WebRoute(
          path: 'error',
          index: homeController.exampleError,
        ),
        WebRoute(
          path: 'dump',
          index: homeController.exampleDump,
        ),
        WebRoute(
          path: 'database',
          methods: [
            RequestMethods.GET,
            RequestMethods.POST,
            RequestMethods.PUT,
            RequestMethods.DELETE,
          ],
          index: homeController.exampleDatabase,
        ),
        WebRoute(
          path: 'pagination',
          methods: [
            RequestMethods.GET,
          ],
          index: homeController.paginationExample,
        ),
        WebRoute(
          path: 'htmler',
          methods: RequestMethods.GET_POST,
          index: htmlerController.exampleHtmler,
        ),
      ],
    ),
    WebRoute(
      path: 'example/mysql',
      extraPath: ['api/example/mysql'],
      methods: RequestMethods.GET_POST,
      index: homeController.exampleMysql,
    ),
    WebRoute(
      path: 'info',
      extraPath: ['api/info'],
      index: homeController.info,
      apiDoc: ApiDocuments.info,
    ),
    WebRoute(
      path: 'api/person',
      extraPath: ['example/person'],
      index: homeController.addNewPerson,
      methods: RequestMethods.ONLY_POST,
      apiDoc: ApiDocuments.allPerson,
    ),
    WebRoute(
      path: 'api/persons',
      extraPath: [
        'example/persons',
        'example/person',
      ],
      index: homeController.allPerson,
      methods: RequestMethods.ONLY_GET,
      apiDoc: ApiDocuments.allPerson,
    ),
    WebRoute(
      path: 'api/person/{id}',
      extraPath: ['example/person/{id}'],
      index: homeController.onePerson,
      methods: RequestMethods.GET_POST,
      apiDoc: ApiDocuments.onePerson,
    ),
    WebRoute(
      path: 'api/person/replace/{id}',
      extraPath: ['example/person/replace/{id}'],
      index: homeController.replacePerson,
      methods: RequestMethods.ONLY_POST,
    ),
    WebRoute(
      path: 'api/person/delete/{id}',
      extraPath: ['example/person/delete/{id}'],
      index: homeController.deletePerson,
      methods: RequestMethods.ONLY_POST,
      apiDoc: ApiDocuments.onePerson,
    ),
    WebRoute(
      path: 'logout',
      methods: RequestMethods.ALL,
      index: authController.logout,
    ),
  ];

  return [
    WebRoute(
      path: '/',
      methods: RequestMethods.ALL,
      controller: homeController,
      children: [
        ...paths,
        WebRoute(
          path: 'fa/*',
          extraPath: Setting.languages.keys.map((e) => '$e/*').toList(),
          index: homeController.changeLanguage,
        )
      ],
    ),
  ];
}
