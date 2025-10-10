import '../controllers/htmler_controller.dart';
import '../configs/setting.dart';
import '../app.dart';
import '../controllers/api_document.dart';
import 'package:webapp/wa_route.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

Future<List<WebRoute>> getWebRoute(WebRequest rq) async {
  final homeController = HomeController();
  final htmlerController = HtmlerController();
  final authController = AuthController(homeController);
  final includeController = IncludeJsController();
  final apiController = WaApiController(
    title: "API Documentation",
    server: server,
  );

  var paths = [
    WebRoute(
      key: 'root.sse',
      path: 'sse',
      methods: RequestMethods.ALL,
      index: homeController.sseExample,
    ),
    WebRoute(
      key: 'root.api.docs',
      path: 'api/docs',
      index: apiController.indexPublic,
    ),
    WebRoute(
      key: 'root.swagger',
      path: 'swagger',
      controller: WaSwaggerController(rq.url('api/docs')),
    ),
    WebRoute(
      key: 'root.ws',
      path: 'ws',
      methods: RequestMethods.ALL,
      index: homeController.socket,
    ),
    WebRoute(
      key: 'root.includes',
      path: 'app/includes.js',
      methods: RequestMethods.ALL,
      index: includeController.index,
    ),
    WebRoute(
      key: 'root.example',
      path: 'example',
      index: homeController.redirectToRoot,
      children: [
        WebRoute(
          key: 'root.localhost',
          path: 'host',
          hosts: ['localhost'],
          ports: [80, 8085],
          index: homeController.renderLocalhost,
          methods: RequestMethods.ALL,
        ),
        WebRoute(
          key: 'root.host',
          path: 'host',
          ports: [80, 8085],
          hosts: ['127.0.0.1'],
          index: homeController.render127001,
          methods: RequestMethods.ALL,
        ),
        WebRoute(
          key: 'root.form',
          path: 'form',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleForm,
        ),
        WebRoute(
          key: 'root.form.post',
          path: 'form',
          methods: RequestMethods.ONLY_POST,
          index: authController.loginPost,
        ),
        WebRoute(
          key: 'root.panel',
          path: 'panel',
          methods: RequestMethods.ALL,
          auth: authController,
          index: homeController.exampleAuth,
          permissions: ['admin'],
        ),
        WebRoute(
          key: 'root.language',
          path: 'language',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleLanguage,
        ),
        WebRoute(
          key: 'root.cookie',
          path: 'cookie',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleCookie,
        ),
        WebRoute(
          key: 'root.cookie.post',
          path: 'cookie',
          methods: RequestMethods.ONLY_POST,
          index: homeController.exampleAddCookie,
        ),
        WebRoute(
          key: 'root.cookie.add',
          path: 'cookie',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleAddCookie,
        ),
        WebRoute(
          key: 'root.route',
          path: 'route',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleRoute,
        ),
        WebRoute(
          key: 'root.socket',
          path: 'socket',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleSocket,
        ),
        WebRoute(
          key: 'root.email',
          path: 'email',
          methods: RequestMethods.ONLY_GET,
          index: homeController.exampleEmail,
        ),
        WebRoute(
          key: 'root.email.post',
          path: 'email',
          methods: RequestMethods.ONLY_POST,
          index: homeController.exampleEmailSend,
        ),
        WebRoute(
          key: 'root.error',
          path: 'error',
          index: homeController.exampleError,
        ),
        WebRoute(
          key: 'root.dump',
          path: 'dump',
          index: homeController.exampleDump,
        ),
        WebRoute(
          key: 'root.database',
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
          key: 'root.pagination',
          path: 'pagination',
          methods: [
            RequestMethods.GET,
          ],
          index: homeController.paginationExample,
        ),
        WebRoute(
          key: 'root.htmler',
          path: 'htmler',
          methods: RequestMethods.GET_POST,
          index: htmlerController.exampleHtmler,
        ),
      ],
    ),
    WebRoute(
      key: 'root.mysql',
      path: 'example/mysql',
      extraPath: ['api/example/mysql'],
      methods: RequestMethods.GET_POST,
      index: homeController.exampleMysql,
    ),
    WebRoute(
      key: 'root.info',
      path: 'info',
      extraPath: ['api/info'],
      index: homeController.info,
      apiDoc: ApiDocuments.info,
    ),
    WebRoute(
      key: 'root.person.post',
      path: 'api/person',
      extraPath: ['example/person'],
      index: homeController.addNewPerson,
      methods: RequestMethods.ONLY_POST,
      apiDoc: ApiDocuments.allPerson,
    ),
    WebRoute(
      key: 'root.persons',
      path: 'example/persons',
      extraPath: [
        'api/persons',
        'example/person',
      ],
      index: homeController.allPerson,
      methods: RequestMethods.ONLY_GET,
      apiDoc: ApiDocuments.allPerson,
    ),
    WebRoute(
      key: 'root.person.show',
      path: 'api/person/{id}',
      extraPath: ['example/person/{id}'],
      index: homeController.onePerson,
      methods: RequestMethods.GET_POST,
      apiDoc: ApiDocuments.onePerson,
    ),
    WebRoute(
      key: 'root.person.replace',
      path: 'api/person/replace/{id}',
      extraPath: ['example/person/replace/{id}'],
      index: homeController.replacePerson,
      methods: RequestMethods.ONLY_POST,
    ),
    WebRoute(
      key: 'root.person.delete',
      path: 'api/person/delete/{id}',
      extraPath: ['example/person/delete/{id}'],
      index: homeController.deletePerson,
      methods: RequestMethods.ONLY_POST,
      apiDoc: ApiDocuments.onePerson,
    ),
    WebRoute(
      key: 'root.logout',
      path: 'logout',
      methods: RequestMethods.ALL,
      index: authController.logout,
    ),
  ];

  return [
    WebRoute(
      key: 'root.home',
      path: '/',
      methods: RequestMethods.ALL,
      controller: homeController,
      children: [
        ...paths,
        WebRoute(
          key: 'root.language.change',
          path: 'fa/*',
          extraPath: Setting.languages.keys.map((e) => '$e/*').toList(),
          index: homeController.changeLanguage,
        )
      ],
    ),
  ];
}
