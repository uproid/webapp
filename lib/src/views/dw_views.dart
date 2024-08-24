import 'package:dweb/src/render/web_request.dart';

class DwView {
  WebRequest rq;
  Map<String, Object?> params;
  String widget;

  DwView({
    required this.rq,
    required this.widget,
    this.params = const {},
  });

  Future<Object> render({toData = false}) async {
    if (toData) {
      return renderData();
    }
    if (widget.isEmpty) {
      return 'Widget of UIView is required.';
    }

    var view = await rq.render(
      path: widget,
      viewParams: {r'$v': await renderData()},
    );
    rq.removeParam(r'$v');

    return view;
  }

  Future<Map<String, Object?>> renderData() async {
    return params;
  }
}
