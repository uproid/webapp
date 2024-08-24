import 'package:dweb/dw_route.dart';
import 'package:dweb/dw_server.dart';
import 'package:dweb/dw_tools.dart';

class DwApiController extends DwController {
  List<Future<List<WebRoute>> Function(WebRequest rq)> router;
  String title;
  String security;
  DwApiController(
    super.rq, {
    required this.router,
    required this.title,
    this.security = 'apiKey',
  });

  @override
  Future<String> index({bool showPublic = false}) async {
    var config = DwServer.config;
    if (!showPublic && !config.isLocalDebug) {
      return rq.renderError(403);
    }

    var paths = {};
    List<WebRoute> routes = [];

    for (var route in router) {
      var addRoute = await route(rq);
      routes = [...routes, ...addRoute];
    }

    var webRoutes = _convert(routes, '', null);

    for (var route in webRoutes) {
      if (route.apiDoc == null) {
        continue;
      }

      var apiDoc = await route.apiDoc!.call();

      if (!route.path.startsWith('/api') || apiDoc == null) {
        continue;
      }
      var res = {};

      for (var method in route.methods) {
        var data = {};
        RegExp regex = RegExp(r'{.*?}');
        data['tags'] = [
          //pathNorm(route.path, normSlashs: true),
          pathNorm(route.path.replaceAll(regex, ''), normSlashs: true),
        ];
        data['summary'] = route.title;
        data['description'] = route.title;
        data['operationId'] = "${route.title} [$method] ${route.path}";
        if (route.auth != null) {
          data['security'] = [
            {
              "auth": ["write", "read"]
            }
          ];
        }
        var requestBody = {};
        var responses = {};
        var parameters = [];

        var doc = ApiDoc(
          body: List.from(apiDoc.body),
          response: Map.from(apiDoc.response),
          parameters: List.from(apiDoc.parameters),
          description: apiDoc.description,
          post: apiDoc.post,
          delete: apiDoc.delete,
          get: apiDoc.get,
          put: apiDoc.put,
        );

        if (method.toLowerCase() == 'get' && doc.get != null) {
          doc.body.addAll(doc.get!.body);
          doc.response.addAll(doc.get!.response);
          doc.parameters.addAll(doc.get!.parameters);
          doc.description = doc.get!.description;
        } else if (method.toLowerCase() == 'post' && doc.post != null) {
          doc.body.addAll(doc.post!.body);
          doc.response.addAll(doc.post!.response);
          doc.parameters.addAll(doc.post!.parameters);
          doc.description = doc.post!.description;
        } else if (method.toLowerCase() == 'put' && doc.put != null) {
          doc.body.addAll(doc.put!.body);
          doc.response.addAll(doc.put!.response);
          doc.parameters.addAll(doc.put!.parameters);
          doc.description = doc.put!.description;
        } else if (method.toLowerCase() == 'delete' && doc.delete != null) {
          doc.body.addAll(doc.delete!.body);
          doc.response.addAll(doc.delete!.response);
          doc.parameters.addAll(doc.delete!.parameters);
          doc.description = doc.delete!.description;
        }

        if (doc.body.isNotEmpty) {
          var responseShema = <dynamic, dynamic>{
            "type": "object",
          };
          var properties = {};
          var description = "";
          for (var pro in doc.body) {
            properties[pro.name] = {
              'type': pro.typeString,
              'format': pro.typeString,
              'examples': [pro.def],
            };

            description +=
                "<b>${pro.name}</b>: ${pro.isRequired ? '* Is required' : 'Not required'} ${pro.description != null ? '| $pro.description' : ""}\n\n";
          }
          responseShema['type'] = 'object';
          responseShema['properties'] = properties;
          requestBody['description'] = description;
          requestBody['content'] = {
            'application/json': {
              'schema': responseShema,
            },
          };
        }

        if (doc.response.isNotEmpty) {
          for (var res in doc.response.keys) {
            var listResponse = doc.response[res]!;
            var responseShema = {};
            var properties = {};
            for (var response in listResponse) {
              properties[response.name] = {
                'type': response.typeString,
                'format': response.typeString,
                'examples': [response.def],
              };
            }
            responseShema['type'] = 'object';
            responseShema['properties'] = properties;
            responses[res] = {
              'description': res,
              'content': {
                'application/json': {
                  'schema': responseShema,
                },
              },
            };
          }
        }

        for (var param in doc.parameters) {
          parameters = [
            ...parameters,
            {
              "name": param.name,
              "in": param.paramIn.toString(),
              "description": param.description ?? "",
              "required": param.isRequired,
              "schema": {
                "type": param.typeString,
                "format": param.typeString,
              }
            },
          ];
        }

        data['responses'] = responses;
        data['requestBody'] = requestBody;
        data['parameters'] = parameters;

        res[method.toLowerCase()] = data;
      }
      var standardPath = route.path;
      if (paths.containsKey(standardPath)) {
        res = {...paths[standardPath], ...res};
      }
      paths = {...paths, standardPath: res};
    }

    var data = {
      "openapi": "3.1.0",
      "info": {
        "title": "$title - OpenAPI 3.1",
        "description": "Dart web Api documentation maker v${config.version}",
        "contact": {"email": "info@uproid.com"},
        "license": {
          "name": "Apache 2.0",
          "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
        },
        "version": config.version
      },
      "externalDocs": {
        "description": "Find out more about DartWeb",
        "url": "http://uproid.com"
      },
      "servers": [
        {"url": config.url()}
      ],
      "paths": {
        ...paths,
      },
      "components": {
        "securitySchemes": {
          "auth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "name": security,
            "in": "header"
          },
        }
      }
    };
    return rq.renderData(data: data);
  }

  Future<String> swagger(
    String docUrl, {
    String swaggerUIPath = '/swagger',
    bool showPublic = false,
  }) async {
    var config = DwServer.config;
    if (showPublic || config.isLocalDebug) {
      return rq.renderView(
        path: """<!DOCTYPE html>
                <html lang="en">
                  <head>
                    <meta charset="UTF-8">
                    <title>Swagger UI</title>
                    <link rel="stylesheet" type="text/css" href="${rq.url('$swaggerUIPath/swagger-ui.css')}" />
                    <link rel="stylesheet" type="text/css" href="${rq.url('$swaggerUIPath/index.css')}" />
                    <link rel="icon" type="image/png" href="${rq.url('$swaggerUIPath/favicon-32x32.png')}" sizes="32x32" />
                    <link rel="icon" type="image/png" href="${rq.url('$swaggerUIPath/favicon-16x16.png')}" sizes="16x16" />
                  </head>

                  <body>
                    <div data-url="$docUrl" id="swagger-ui"></div>
                    <script src="${rq.url('$swaggerUIPath/swagger-ui-bundle.js')}" charset="UTF-8"> </script>
                    <script src="${rq.url('$swaggerUIPath/swagger-ui-standalone-preset.js')}" charset="UTF-8"> </script>
                    <script src="${rq.url('$swaggerUIPath/swagger-initializer.js')}" charset="UTF-8"> </script>
                  </body>
                </html>""",
        isFile: false,
      );
    }

    return rq.renderError(403);
  }

  List<WebRoute> _convert(
      List<WebRoute> routes, String parentPath, DwAuthController? auth) {
    var result = <WebRoute>[];

    for (final route in routes) {
      route.path = '/${pathNorm(joinPaths([
                '/',
                parentPath,
                route.path
              ]), normSlashs: true)}';
      route.auth ??= auth;
      result.add(route);

      if (route.children.isNotEmpty) {
        result.addAll(
          _convert(
            route.children,
            route.path,
            route.auth,
          ),
        );

        for (var epath in route.extraPath) {
          result.addAll(
            _convert(
              route.children,
              epath,
              route.auth,
            ),
          );
        }
      }
    }

    return result;
  }
}
