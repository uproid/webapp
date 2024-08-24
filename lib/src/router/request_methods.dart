// ignore_for_file: constant_identifier_names, non_constant_identifier_names

class RequestMethods {
  static const GET = "GET";
  static const PUT = "PUT";
  static const POST = "POST";
  static const HEAD = "HEAD";
  static const DELETE = "DELETE";
  static const INSERT = "INSERT";
  static const CONNECT = "CONNECT";
  static const OPTIONS = "OPTIONS";
  static const TRACE = "TRACE";
  static const PATCH = "PATCH";

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

  static List<String> get GET_POST => [
        POST,
        GET,
      ];

  static List<String> get ONLY_GET => [GET];
  static List<String> get ONLY_POST => [POST];
  static List<String> get ONLY_DELETE => [DELETE];
  static List<String> get ONLY_PUT => [PUT];
  static List<String> get ONLY_INSERT => [INSERT];
}
