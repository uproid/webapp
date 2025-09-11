import '../render/web_request.dart';

/// A base class for controllers in the web application.
///
/// This class implements the [RouteRepos] interface and provides a basic implementation
/// for handling web requests. It includes a method for rendering the index and a method
/// for providing a string representation of the controller instance.
class WaController implements RouteRepos {
  /// The [WebRequest] object representing the current web request.
  WebRequest rq;

  /// Creates a [WaController] instance.
  ///
  /// The [rq] parameter is required for initializing the controller with the current web request.
  WaController(
    this.rq,
  );

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

/// An abstract class defining the interface for route repositories.
///
/// Classes implementing this interface must provide an implementation for the [index]
/// method, which is intended for handling requests to the index route.
abstract class RouteRepos {
  /// An asynchronous method for handling requests to the index route.
  ///
  /// Subclasses should override this method to provide specific functionality for
  /// rendering the index view or handling index-related requests.
  ///
  /// Returns a [Future<String>] that resolves to the result of the index operation.
  Future<String> index();
}
