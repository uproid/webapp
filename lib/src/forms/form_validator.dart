import 'dart:convert';
import '../render/web_request.dart';

typedef ValidatorEvent<T> = FieldValidateResult Function(T value);

class FormValidator {
  WebRequest rq;
  Map<String, List<ValidatorEvent>> fields;
  Object success;
  Object failed;
  String name;
  Map<String, Object> extraData;

  FormValidator({
    required this.rq,
    required this.fields,
    required this.name,
    this.failed = 'is-invalid',
    this.success = '',
    this.extraData = const {},
  });

  /// `data` Used when you don't want load data from request like POST and GET
  Future<bool> validate({
    Map data = const {},
  }) async {
    var res = await validateAndForm(data: data);
    return res.result;
  }

  Future<({bool result, Map<String, dynamic> form})> validateAndForm({
    Map data = const {},
  }) async {
    bool result = true;
    var thisForm = <String, dynamic>{};

    for (var fieldName in fields.keys) {
      var fieldResult = <String, dynamic>{};
      Object fieldValue;
      if (data.isEmpty) {
        fieldValue = rq.data(fieldName);
      } else {
        fieldValue = data[fieldName] ?? extraData[fieldName];
      }

      fieldResult["value"] = fieldValue;

      var fieldEvents = fields[fieldName] ?? [];

      var success = true;
      var errors = [];
      for (var validateField in fieldEvents) {
        FieldValidateResult check = validateField(fieldValue);
        if (!check.success) {
          success = false;
        }

        errors.addAll(check.errors);
      }

      fieldResult['valid'] = success ? this.success : failed;
      fieldResult['error'] = errors.join(',');
      fieldResult['errorHtml'] = errors.join('<br/>');
      fieldResult['errors'] = errors;
      fieldResult['success'] = success;
      fieldResult['faild'] = !success;
      if (!success) {
        result = false;
      }

      thisForm[fieldName] = fieldResult;
    }

    extraData.forEach((key, value) {
      if (!thisForm.containsKey(key)) {
        thisForm[key] = {
          'success': true,
          'faild': false,
          'error': '',
          'errors': [],
          'errorHtml': '',
          'valid': success,
          'value': value,
        };
      }
    });

    rq.addValidator(name, thisForm);

    return (result: result, form: thisForm);
  }

  static Future<FormValidator> filling({
    required WebRequest rq,
    required String name,
    required Map data,
  }) async {
    var fields = <String, List<ValidatorEvent>>{};
    for (var item in data.keys) {
      fields[item] = <ValidatorEvent>[];
    }

    final emptyValidator = FormValidator(rq: rq, fields: fields, name: name);
    await emptyValidator.validate(data: data);
    return emptyValidator;
  }
}

class FieldValidateResult {
  bool success;
  List<String> errors;
  String error;

  FieldValidateResult({
    this.success = false,
    this.errors = const [],
    this.error = '',
  }) {
    if (error.isNotEmpty) {
      errors = [...errors, error];
    }
  }
}

class FieldValidator {
  static ValidatorEvent requiredField() => (value) {
        var res = (value != null && value.toString().trim().isNotEmpty);
        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.required',
        );
      };

  static ValidatorEvent requiredFieldMultiLanguage() {
    return (value) {
      var res = (value != null && value.toString().trim().isNotEmpty);

      if (!res) {
        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.required',
        );
      }

      Map<String, String> resMap = {};

      try {
        var json = jsonDecode(value.toString());
        for (var key in json.keys) {
          if (json[key] != null && json[key]!.trim().isNotEmpty) {
            resMap[key] = json[key]!.trim();
          }
        }
      } catch (e) {
        resMap = {};
      }

      return FieldValidateResult(
        success: resMap.isNotEmpty,
        error: resMap.isNotEmpty ? '' : 'error.field.required',
      );
    };
  }

  static ValidatorEvent fieldLength({
    int? max,
    int? min,
  }) {
    return (value) {
      var res = true;
      var error = <String>[];

      if (max != null) {
        if (value.toString().length > max) {
          res = false;
          error.add('error.field.max#{$max}');
        }
      }

      if (min != null) {
        if (value.toString().length < min) {
          res = false;
          error.add('error.field.min#{$min}');
        }
      }

      return FieldValidateResult(
        success: res,
        error: res ? '' : 'error.field',
        errors: error,
      );
    };
  }
}
