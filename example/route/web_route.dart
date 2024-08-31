import 'package:webapp/wa_route.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

Future<List<WebRoute>> getWebRoute(WebRequest rq) async {
  final homeController = HomeController(rq);
  final authController = AuthController(rq, homeController);
  final includeController = IncludeJsController(rq);

  var paths = [
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
      ],
    ),
    WebRoute(
      path: 'info',
      extraPath: ['api/info'],
      rq: rq,
      index: homeController.info,
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
          extraPath: [
            'en/*',
            'nl/*',
          ],
          rq: rq,
          index: homeController.changeLanguage,
        )
      ],
    ),
  ];
}
