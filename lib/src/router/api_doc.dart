/// This class used to make an Model for openapi / swagger
class ApiDoc {
  List<ApiParameter> parameters;
  List<ApiBodyField> body;
  Map<String, List<ApiResponse>> response;
  String? description;

  ApiDoc? post;
  ApiDoc? get;
  ApiDoc? put;
  ApiDoc? delete;

  ApiDoc({
    //For all methods
    this.parameters = const [],
    this.body = const [],
    this.response = const {},
    this.description,
    //For special Method
    this.delete,
    this.get,
    this.post,
    this.put,
  });

  static String dartTypeToOpenApi(String type) {
    type = type.split('<')[0];
    switch (type) {
      case 'int':
        return 'integer';
      case 'double':
        return 'number';
      case 'num':
        return 'number';
      case 'bool':
        return 'boolean';
      case 'String':
        return 'string';
      case 'List':
        return 'array';
      case 'Map':
        return 'object';

      default:
        return type;
    }
  }
}

class ApiParameter<T> {
  String name;
  Object? def;
  String? description;
  bool isRequired;
  String get typeString => ApiDoc.dartTypeToOpenApi(T.toString());
  Type get type => T.runtimeType;
  ParamIn paramIn;

  ApiParameter(
    this.name, {
    this.def,
    this.description,
    this.isRequired = false,
    this.paramIn = ParamIn.query,
  });
}

class ApiBodyField<T> {
  String name;
  Object? def;
  String? description;
  bool isRequired;
  String get typeString => ApiDoc.dartTypeToOpenApi(T.toString());
  Type get type => T.runtimeType;
  ApiBodyField(
    this.name, {
    this.def,
    this.description,
    this.isRequired = false,
  });
}

class ApiResponse<T> {
  String name;
  Object? def;
  String? description;
  String get typeString => ApiDoc.dartTypeToOpenApi(T.toString());
  Type get type => T.runtimeType;
  ApiResponse(
    this.name, {
    this.def,
    this.description,
  });
}

enum ParamIn {
  query,
  header,
  path,
  cookie;

  @override
  String toString() {
    switch (this) {
      case ParamIn.query:
        return 'query';
      case ParamIn.path:
        return 'path';
      case ParamIn.cookie:
        return 'cookie';
      case ParamIn.header:
        return 'header';
    }
  }
}
