// ignore_for_file: constant_identifier_names, non_constant_identifier_names

/// A utility class that provides constants and predefined lists for various HTTP request methods.
/// This class includes constants for common HTTP methods and provides convenience lists for
/// frequently used method combinations. It is useful for standardizing and managing HTTP method
/// strings throughout an application.
class RequestMethods {
  /// The HTTP GET method.
  static const String GET = "GET";

  /// The HTTP PUT method.
  static const String PUT = "PUT";

  /// The HTTP POST method.
  static const String POST = "POST";

  /// The HTTP HEAD method.
  static const String HEAD = "HEAD";

  /// The HTTP DELETE method.
  static const String DELETE = "DELETE";

  /// The HTTP INSERT method (non-standard, generally used for custom purposes).
  static const String INSERT = "INSERT";

  /// The HTTP CONNECT method.
  static const String CONNECT = "CONNECT";

  /// The HTTP OPTIONS method.
  static const String OPTIONS = "OPTIONS";

  /// The HTTP TRACE method.
  static const String TRACE = "TRACE";

  /// The HTTP PATCH method.
  static const String PATCH = "PATCH";

  /// A list of all HTTP methods supported by this class.
  ///
  /// Includes: GET, POST, PUT, HEAD, DELETE, INSERT, CONNECT, OPTIONS, TRACE, PATCH.
  static List<String> get ALL => [
        GET,
        POST,
        PUT,
        HEAD,
        DELETE,
        INSERT,
        CONNECT,
        OPTIONS,
        TRACE,
        PATCH,
      ];

  /// A list of commonly used HTTP methods for request submissions.
  ///
  /// Includes: POST, GET.
  static List<String> get GET_POST => [POST, GET];

  /// A list containing only the HTTP GET method.
  static List<String> get ONLY_GET => [GET];

  /// A list containing only the HTTP POST method.
  static List<String> get ONLY_POST => [POST];

  /// A list containing only the HTTP DELETE method.
  static List<String> get ONLY_DELETE => [DELETE];

  /// A list containing only the HTTP PUT method.
  static List<String> get ONLY_PUT => [PUT];

  /// A list containing only the HTTP INSERT method.
  static List<String> get ONLY_INSERT => [INSERT];

  static List<String> get GET_ONLY => ONLY_GET;
  static List<String> get POST_ONLY => ONLY_POST;
  static List<String> get DELETE_ONLY => ONLY_DELETE;
  static List<String> get PUT_ONLY => ONLY_PUT;
  static List<String> get INSERT_ONLY => ONLY_INSERT;
}
