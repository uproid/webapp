import 'model_less.dart';

class MLess {
  late ModelLess model;

  MLess({ModelLess? model}) {
    this.model = model ?? ModelLess.fromJson("{}");
  }

  @override
  String toString() {
    return model.toString();
  }
}
