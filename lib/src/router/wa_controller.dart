import '../render/web_request.dart';
import '../core/request_context.dart';

/// Base controller class for handling HTTP requests in the web application.
///
/// [WaController] serves as the foundation for all request handlers in the framework.
/// It provides access to the current request context and implements the [RouteRepos]
/// interface for standardized request handling. Controllers are typically used to
/// organize related request handling logic and can be associated with routes to
/// process incoming HTTP requests.
///
/// The controller automatically has access to the current [WebRequest] through
/// the [rq] getter, eliminating the need to pass request objects manually.
/// This design leverages the Zone-based [RequestContext] system for thread-safe
/// request handling.
///
/// Key features:
/// - Automatic access to current request context
/// - Thread-safe request handling through Zone isolation
/// - Standardized interface for index route handling
/// - Built-in string representation for debugging and introspection
///
/// Example usage:
/// ```dart
/// class UserController extends WaController {
///   @override
///   Future<String> index() async {
///     final users = await userService.getAllUsers();
///     return rq.renderJson(users);
///   }
///
///   Future<String> show() async {
///     final id = rq.params['id'];
///     final user = await userService.getUserById(id);
///     return rq.renderJson(user);
///   }
/// }
///
/// // Route configuration
/// WebRoute(
///   path: '/users',
///   controller: UserController(),
/// )
/// ```
class WaController implements RouteRepos {
  /// Gets the current WebRequest from the request context
  WebRequest get rq => RequestContext.rq;

  /// Creates a [WaController] instance.
  ///
  /// The [rq] parameter is optional now as we use RequestContext to access the current request.
  WaController([WebRequest? rq]);

  /// Provides an asynchronous method for rendering the index page of the controller.
  ///
  /// This method returns an empty string by default. Subclasses should override this method
  /// to provide specific functionality for rendering the index view.
  ///
  /// Returns a [Future<String>] that resolves to an empty string.
  @override
  Future<String> index() async => "";

  /// Returns a string representation of the controller.
  ///
  /// If [short] is true, the method returns a short representation by extracting and
  /// returning the last part of the class name from the superclass’s `toString` method,
  /// removing any single quotes.
  ///
  /// If [short] is false, the method returns the full string representation of the class.
  ///
  /// Returns a [String] representing the controller.
  @override
  String toString({bool short = false}) {
    if (short) {
      return super.toString().split(' ').last.replaceAll("'", '');
    }
    return super.toString();
  }
}

/// Interface defining the contract for route request handlers.
///
/// [RouteRepos] establishes a standardized interface that all route handlers
/// must implement. It serves as a contract ensuring that request handling
/// components provide consistent entry points for processing HTTP requests.
///
/// The interface is designed to support the routing system's need for a
/// unified way to invoke request handlers, regardless of their specific
/// implementation details. This abstraction enables the framework to
/// treat different types of controllers uniformly during route processing.
///
/// Implementations should:
/// - Handle the primary route endpoint logic in [index]
/// - Return appropriate response content as a string
/// - Manage any necessary asynchronous operations
/// - Utilize the current request context for accessing request data
///
/// This interface is primarily implemented by [WaController] and its subclasses,
/// but can be implemented by any class that needs to handle route requests.
abstract class RouteRepos {
  /// Handles the primary request processing for this route handler.
  ///
  /// This method serves as the main entry point for processing HTTP requests
  /// when no specific action is specified. It should contain the core logic
  /// for handling the request and generating an appropriate response.
  ///
  /// The method is called by the routing system when a request matches the
  /// associated route pattern. Implementations should:
  /// - Access request data through [RequestContext.rq]
  /// - Process the request according to business logic
  /// - Generate and return response content
  /// - Handle any errors appropriately
  ///
  /// Returns a [Future<String>] containing the response content. This could be:
  /// - HTML content for web pages
  /// - JSON data for API endpoints
  /// - Redirect responses
  /// - Error messages
  /// - Empty string for no-content responses
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<String> index() async {
  ///   final data = await service.getData();
  ///   return RequestContext.rq.renderJson(data);
  /// }
  /// ```
  Future<String> index();
}
