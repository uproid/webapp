import '../configs/setting.dart';
import '../app.dart';
import '../controllers/api_document.dart';
import 'package:webapp/wa_route.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

Future<List<WebRoute>> getWebRoute(WebRequest rq) async {
  final homeController = HomeController(rq);
  final authController = AuthController(rq, homeController);
  final includeController = IncludeJsController(rq);
  final apiController = WaApiController(
    title: "API Documentation",
    rq,
    server: server,
  );

  var paths = [
    WebRoute(
      path: 'api/docs',
      rq: rq,
      index: () {
        return apiController.index(showPublic: true);
      },
    ),
    WebRoute(
      path: 'swagger',
      rq: rq,
      index: () {
        return rq.redirect(
          'https://petstore.swagger.io/?url=${rq.url('api/docs')}',
        );
      },
    ),
    WebRoute(
      path: 'ws',
      methods: RequestMethods.ALL,
      rq: rq,
      index: homeController.socket,
    ),
    WebRoute(
      path: 'app/includes.js',
      methods: RequestMethods.ALL,
      rq: rq,
      index: includeController.index,
    ),
    WebRoute(
      path: 'example',
      rq: rq,
      index: () => rq.redirect('/'),
      children: [
        WebRoute(
          path: 'host',
          rq: rq,
          hosts: ['localhost'],
          ports: [80, 8085],
          index: () => rq.renderString(text: 'Localhost'),
          methods: RequestMethods.ALL,
        ),
        WebRoute(
          path: 'host',
          rq: rq,
          ports: [80, 8085],
          hosts: ['127.0.0.1'],
          index: () => rq.renderString(text: '127.0.0.1'),
          methods: RequestMethods.ALL,
        ),
        WebRoute(
          path: 'form',
          methods: RequestMethods.ONLY_GET,
          rq: rq,
          index: homeController.exampleForm,
        ),
        WebRoute(
          path: 'form',
          methods: RequestMethods.ONLY_POST,
          rq: rq,
          index: authController.loginPost,
        ),
        WebRoute(
          path: 'panel',
          methods: RequestMethods.ALL,
          rq: rq,
          auth: authController,
          index: homeController.exampleAuth,
          permissions: ['admin'],
        ),
        WebRoute(
          path: 'language',
          methods: RequestMethods.ONLY_GET,
          rq: rq,
          index: homeController.exampleLanguage,
        ),
        WebRoute(
          path: 'cookie',
          methods: RequestMethods.ONLY_GET,
          rq: rq,
          index: homeController.exampleCookie,
        ),
        WebRoute(
          path: 'cookie',
          methods: RequestMethods.ONLY_POST,
          rq: rq,
          index: homeController.exampleAddCookie,
        ),
        WebRoute(
          path: 'cookie',
          methods: RequestMethods.ONLY_GET,
          rq: rq,
          index: homeController.exampleAddCookie,
        ),
        WebRoute(
          path: 'route',
          methods: RequestMethods.ONLY_GET,
          rq: rq,
          index: homeController.exampleRoute,
        ),
        WebRoute(
          path: 'socket',
          methods: RequestMethods.ONLY_GET,
          rq: rq,
          index: homeController.exampleSocket,
        ),
        WebRoute(
          path: 'email',
          methods: RequestMethods.ONLY_GET,
          rq: rq,
          index: homeController.exampleEmail,
        ),
        WebRoute(
          path: 'email',
          methods: RequestMethods.ONLY_POST,
          rq: rq,
          index: homeController.exampleEmailSend,
        ),
        WebRoute(
          path: 'error',
          rq: rq,
          index: homeController.exampleError,
        ),
        WebRoute(
          path: 'dump',
          rq: rq,
          index: homeController.exampleDump,
        ),
        WebRoute(
          path: 'database',
          rq: rq,
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
          rq: rq,
          methods: [
            RequestMethods.GET,
          ],
          index: homeController.paginationExample,
        ),
      ],
    ),
    WebRoute(
      path: 'info',
      extraPath: ['api/info'],
      rq: rq,
      index: homeController.info,
      apiDoc: ApiDocuments.info,
    ),
    WebRoute(
      path: 'api/person',
      extraPath: ['example/person'],
      rq: rq,
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
      rq: rq,
      index: homeController.allPerson,
      methods: RequestMethods.ONLY_GET,
      apiDoc: ApiDocuments.allPerson,
    ),
    WebRoute(
      path: 'api/person/{id}',
      extraPath: ['example/person/{id}'],
      rq: rq,
      index: homeController.onePerson,
      methods: RequestMethods.ONLY_GET,
      apiDoc: ApiDocuments.onePerson,
    ),
    WebRoute(
      path: 'api/person/{id}',
      extraPath: ['example/person/{id}'],
      rq: rq,
      index: homeController.updateOrDeletePerson,
      methods: RequestMethods.ONLY_POST,
      apiDoc: ApiDocuments.onePerson,
    ),
    WebRoute(
      path: 'api/person/replace/{id}',
      extraPath: ['example/person/replace/{id}'],
      rq: rq,
      index: homeController.replacePerson,
      methods: RequestMethods.ONLY_POST,
    ),
    WebRoute(
      path: 'api/person/{id}',
      extraPath: ['example/person/{id}'],
      rq: rq,
      index: homeController.deletePerson,
      methods: RequestMethods.ONLY_DELETE,
      apiDoc: ApiDocuments.onePerson,
    ),
    WebRoute(
      path: 'logout',
      methods: RequestMethods.ALL,
      rq: rq,
      index: authController.logout,
    ),
  ];

  return [
    WebRoute(
      path: '/',
      rq: rq,
      methods: RequestMethods.ALL,
      controller: homeController,
      children: [
        ...paths,
        WebRoute(
          path: 'fa/*',
          extraPath: Setting.languages.keys.map((e) => '$e/*').toList(),
          rq: rq,
          index: homeController.changeLanguage,
        )
      ],
    ),
  ];
}
