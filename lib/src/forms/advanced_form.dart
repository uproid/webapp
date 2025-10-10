import 'package:webapp/wa_model_less.dart';
import 'package:webapp/wa_route.dart';
import 'package:webapp/wa_ui.dart';

abstract class AdvancedForm {
  WebRequest get rq => RequestContext.rq;
  String name = 'form';
  String widget = 'forms/form.j2.html';
  Map<String, dynamic> initData = {};
  var _isChecked = false;
  bool get isChecked => _isChecked;
  Map? _checkedResult;

  List<Field> _fields = [];
  List<Field> fields();

  bool get posted => rq.method == RequestMethods.POST;

  AdvancedForm({this.initData = const {}}) {
    _fields = fields();
    for (var field in _fields) {
      if (initData.containsKey(field.name)) {
        field.initValue = initData[field.name] ?? field.initValue;
      }
    }
    _init();
  }

  void _init() {
    var initializer = {
      'widget': widget,
      'name': name,
      'success': true,
    };

    for (var field in _fields) {
      initializer[field.name] = {
        'value': field.initValue,
        'errors': <String>[],
        'error': '',
        'success': true,
        'failed': false,
      };
    }
    rq.addParam(name, initializer);
  }

  Future<bool> check({
    Map fill = const {},
    Function(Map<String, dynamic>)? onValid,
    Function(Map<String, dynamic>)? onInvalid,
  }) async {
    var dataRequest = {
      ...rq.getAll(),
      ...fill,
    };

    var form = {
      'widget': widget,
      'name': name,
      'success': true,
    };

    var success = true;
    for (var field in _fields) {
      var value = _setValue(field, dataRequest[field.name]);
      var resField = await field.validate(value);
      success &= resField['success'];
      form[field.name] = resField;
    }
    form['success'] = success;
    rq.addParam(name, form);
    _isChecked = true;
    _checkedResult = form;

    if (success) {
      await onValid?.call(form);
    } else {
      await onInvalid?.call(form);
    }

    return success;
  }

  Future<Map<String, dynamic>> checkAndData({
    bool fillEmpties = false,
  }) async {
    var res = <String, dynamic>{};
    if (await check()) {
      for (var field in _fields) {
        var value = _checkedResult![field.name]['value'];
        if (fillEmpties) {
          res[field.name] = _checkedResult![field.name]['value'];
        } else if (value != null && value.toString() != '') {
          res[field.name] = _checkedResult![field.name]['value'];
        }
      }
    }
    return res;
  }

  Future<void> initOptions() async {
    var res = rq.getParam(this.name) as Map<String, dynamic>? ?? {};
    for (var field in _fields) {
      res[field.name]['options'] = await field.initOptions?.call(field) ?? [];
    }
    rq.addParam(name, res);
  }

  dynamic _setValue(Field field, dynamic value) {
    if ((value == null || value.toString() == '') && field.type == bool) {
      return 'false';
    }
    var res = value ?? field.initValue;
    return res;
  }

  T get<T>(String key, {T? def}) {
    if (!_isChecked) {
      throw Exception('Form not checked yet. Call check() first.');
    }
    return ObjectDescovery.descovr(_checkedResult![key]['value'], T, def: def)
        as T;
  }

  List<String> get fieldKeys => _fields.map((field) => field.name).toList();
}

class Field {
  String name;
  List<ValidatorEvent> validators;
  Object? initValue;
  Type type = String;
  Function(Field field)? initOptions = (field) async => [];

  Field(
    this.name, {
    this.validators = const [],
    this.initValue = null,
    this.type = String,
    this.initOptions,
  });

  Future<Map<String, dynamic>> validate(dynamic value) async {
    var res = <String, dynamic>{
      'success': true,
      'errors': <String>[],
      'error': '',
      'value': value,
      'failed': false,
      'options': await initOptions?.call(this) ?? [],
    };
    var errors = <String>[];
    bool success = true;

    for (var validator in validators) {
      var result = await validator(value);
      success &= result.success;
      errors.addAll(result.errors);
    }

    res['errors'] = errors;
    res['error'] = errors.isNotEmpty ? errors.first : '';
    res['success'] = success;
    res['failed'] = !success;
    return res;
  }
}
