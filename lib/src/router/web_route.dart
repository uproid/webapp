import 'dart:async';
import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_tools.dart';

/// Defines a web route configuration for HTTP request handling in the application.
///
/// The [WebRoute] class represents a single route definition that specifies how
/// incoming HTTP requests should be matched and handled. It supports advanced
/// routing features including pattern matching, HTTP method filtering, host/port
/// restrictions, nested routing, authentication, and authorization.
///
/// Key features:
/// - Path pattern matching with wildcards (`/api/*`) and parameters (`/users/{id}`)
/// - HTTP method restrictions (GET, POST, PUT, DELETE, etc.)
/// - Host and port-based routing for multi-tenant applications
/// - Nested route hierarchies for organized route structures
/// - Integration with authentication and authorization systems
/// - Controller-based and function-based request handling
/// - Widget/template rendering capabilities
/// - API documentation generation support
///
/// Example usage:
/// ```dart
/// // Simple route
/// WebRoute(
///   path: '/users',
///   methods: [RequestMethods.GET],
///   index: () async => 'User list',
/// )
///
/// // Parameterized route with authentication
/// WebRoute(
///   path: '/users/{id}',
///   methods: [RequestMethods.GET, RequestMethods.PUT],
///   auth: UserAuthController(),
///   permissions: ['user.read', 'user.edit'],
///   controller: UserController(),
/// )
///
/// // Nested route structure
/// WebRoute(
///   path: '/api',
///   children: [
///     WebRoute(path: '/users', controller: UserApiController()),
///     WebRoute(path: '/posts', controller: PostApiController()),
///   ],
/// )
/// ```
class WebRoute {
  /// The primary path of the route. For example, `/test` or `/test/*`.
  /// If using `/test/*`, it will match all sub-paths under `/test`.
  late String path;

  /// The primary hostname constraints for this route.
  ///
  /// Specifies which hostnames this route should respond to. Useful for
  /// multi-tenant applications or domain-specific routing.
  /// - `['*']` (default): Matches all hostnames
  /// - `['example.com']`: Matches only requests to example.com
  /// - `['api.example.com', 'admin.example.com']`: Matches specific subdomains
  late List<String> hosts;

  /// The port number constraints for this route.
  ///
  /// Restricts the route to specific port numbers. Useful for development
  /// environments or when running multiple services on different ports.
  /// - `[]` (default): Matches all ports
  /// - `[8080]`: Matches only requests on port 8080
  /// - `[80, 443]`: Matches HTTP and HTTPS standard ports
  late List<int> ports;

  /// Additional main paths for this route. This allows for multiple matching paths.
  late List<String> extraPath;

  /// List of HTTP methods allowed for this route. For example, `POST`, `GET`, `HEAD`, etc.
  late List<String> methods;

  /// The controller associated with this route. This is an instance of [WaController]
  /// that will handle the request for this route.
  late WaController? controller;

  /// A function representing the main controller function to load for this route.
  /// This is typically used to render the index of the controller.
  late Future<String> Function()? index;

  /// An optional [WaAuthController] for handling authentication and session checks
  /// for this route.
  late WaAuthController? auth;

  /// Permissions required for this route. Authentication is needed to use these permissions.
  late List<String> permissions = [];

  /// Path to the widget to be loaded as content for this route.
  late String widget;

  /// Default variable parameters to use in the content.
  late Map<String, Object?> params;

  /// The title of the page, which can be used as `<?= $e.pageTitle ?>`.
  late String title;

  /// Paths that should not be included in all sub-paths of `/*`.
  late List<String> excludePaths;

  /// Sub-routes of the current route, defining a tree structure of routes.
  List<WebRoute> children;

  /// Function to generate API documentation for this route.
  Future<ApiDoc>? Function()? apiDoc;

  /// The path after rendering, used internally for path rendering.
  String _pathAfterRender = '';

  /// Sets the rendered path for this route.
  ///
  /// [path] is the full path after rendering.
  void setPathRender(String path) => _pathAfterRender = path;

  /// Gets the path after rendering.
  ///
  /// Returns the full path after rendering.
  String getPathRender() => _pathAfterRender;

  /// Creates a [WebRoute] instance with the specified parameters.
  ///
  /// [path] and [rq] are required parameters. All other parameters have default values.
  WebRoute({
    required this.path,
    @Deprecated('This parameter will be removed in future versions. 3.0.0')
    WebRequest? rq,
    this.extraPath = const [],
    this.methods = const [RequestMethods.GET],
    this.controller,
    this.widget = "",
    this.index,
    this.auth,
    this.children = const [],
    this.params = const {},
    this.title = '',
    this.excludePaths = const [],
    this.apiDoc,
    this.permissions = const [],
    this.hosts = const ['*'],
    this.ports = const [],
  }) : super();

  /// Validates if the current HTTP request method is allowed for this route.
  ///
  /// Checks the incoming request's HTTP method against the route's configured
  /// allowed methods list. This is used during the routing process to determine
  /// if a route should handle a specific request.
  ///
  /// Returns `true` if the request method is in the [methods] list, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// // Route configured for GET and POST
  /// final route = WebRoute(
  ///   path: '/api/users',
  ///   methods: [RequestMethods.GET, RequestMethods.POST],
  /// );
  ///
  /// // For a GET request: returns true
  /// // For a DELETE request: returns false
  /// ```
  bool allowMethod() {
    return (methods.contains(RequestContext.rq.method));
  }

  /// Converts the route to a list of maps representing its details.
  ///
  /// [parentPath] is the base path for the route.
  /// [hasAuth] indicates whether the route requires authentication.
  /// [method] is the HTTP method being used.
  ///
  /// Returns a list of maps containing details about the route.
  List<Map> toMap(String parentPath, bool hasAuth, String method) {
    var res = <Map>[];
    final endpoint = endpointNorm([parentPath, path]);
    res.add({
      'path': path,
      'fullPath': endpoint,
      'hasAuth': hasAuth || auth != null,
      'method': method,
      'value': "[$method]$endpoint",
      'type': endpoint.startsWith('/api/') ? 'API' : 'WEB',
      'permissions': permissions,
      'controller': controller?.toString(short: true),
      'index':
          index?.toString().split(' ').last.replaceAll(RegExp(r"[:'.]"), ''),
      'hosts': hosts,
      'ports': ports,
    });

    for (var epath in extraPath) {
      var eEndpoint = endpointNorm([parentPath, epath]);
      res.add({
        'path': epath,
        'fullPath': eEndpoint,
        'hasAuth': hasAuth || auth != null,
        'method': method,
        'value': "[$method]$eEndpoint",
        'type': eEndpoint.startsWith('/api/') ? 'API' : 'WEB',
        'permissions': permissions,
        'controller': controller?.toString(short: true),
        'index':
            index?.toString().split(' ').last.replaceAll(RegExp(r"[:'.]"), ''),
        'hosts': hosts,
        'ports': ports,
      });
    }

    return res;
  }

  /// Creates multiple [WebRoute] instances with shared configuration.
  ///
  /// This factory method simplifies the creation of multiple routes that share
  /// the same configuration (methods, controller, authentication, etc.) but
  /// have different paths. It's particularly useful for creating route groups
  /// or when you need similar routes for different endpoints.
  ///
  /// All parameters except [paths] are optional and will be applied to all
  /// created routes. Each path in the [paths] list will generate a separate
  /// [WebRoute] instance with the shared configuration.
  ///
  /// [paths] List of path patterns for which to create routes
  /// [extraPath] Additional path aliases for each route
  /// [methods] HTTP methods allowed for all routes (defaults to GET)
  /// [controller] Controller instance to handle requests for all routes
  /// [index] Function to handle index requests for all routes
  /// [auth] Authentication controller for all routes
  /// [permissions] Required permissions for all routes
  /// [widget] Widget/template path for all routes
  /// [params] Default parameters for all routes
  /// [title] Page title for all routes
  /// [excludePaths] Paths to exclude from wildcard matching
  /// [children] Child routes for all routes
  /// [apiDoc] API documentation generator function
  /// [hosts] Host restrictions for all routes
  /// [ports] Port restrictions for all routes
  ///
  /// Returns a list of configured [WebRoute] instances.
  ///
  /// Example:
  /// ```dart
  /// final userRoutes = WebRoute.makeList(
  ///   paths: ['/users', '/members', '/people'],
  ///   methods: [RequestMethods.GET, RequestMethods.POST],
  ///   controller: UserController(),
  ///   auth: UserAuthController(),
  ///   permissions: ['user.read'],
  /// );
  /// ```
  static List<WebRoute> makeList({
    required List<String> paths,
    List<String> extraPath = const [],
    List<String> methods = const [RequestMethods.GET],
    WaController? controller,
    Future<String> Function()? index,
    WaAuthController? auth,
    List<String> permissions = const [],
    String widget = "",
    Map<String, Object?> params = const {},
    String title = "",
    List<String> excludePaths = const [],
    List<WebRoute> children = const [],
    Future<ApiDoc>? Function()? apiDoc,
    List<String> hosts = const ['*'],
    List<int> ports = const [],
  }) {
    var res = <WebRoute>[];

    for (var path in paths) {
      final route = WebRoute(
        path: path,
        index: index,
        apiDoc: apiDoc,
        auth: auth,
        children: children,
        controller: controller,
        excludePaths: excludePaths,
        extraPath: extraPath,
        methods: methods,
        params: params,
        permissions: permissions,
        title: title,
        widget: widget,
        hosts: hosts,
        ports: ports,
      );
      res.add(route);
    }

    return res;
  }
}
