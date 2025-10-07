import 'package:webapp/src/widgets/widget_swagger.dart';
import 'package:webapp/wa_route.dart';

class WaSwaggerController extends WaController {
  final String urlApiDocs;
  WaSwaggerController(this.urlApiDocs);

  @override
  Future<String> index() async {
    return rq.renderTag(
        tag: WidgetSwagger().generateHtml!({
      'url': urlApiDocs,
    }));
  }
}
