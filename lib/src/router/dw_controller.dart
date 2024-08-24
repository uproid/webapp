import '../render/web_request.dart';

class DwController implements RouteRepos {
  WebRequest rq;

  DwController(
    this.rq,
  );

  @override
  Future<String> index() async => "";

  @override
  String toString({var short = false}) {
    if (short) {
      return super.toString().split(' ').last.replaceAll("'", '');
    }
    return super.toString();
  }
}

abstract class RouteRepos {
  Future<String> index();
}
