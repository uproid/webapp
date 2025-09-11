import 'package:webapp/mongo_dart.dart';
import 'package:webapp/wa_model.dart';

class MockUserModel extends DBModel {
  String name = "John Doe";
  int age = 25;
  String email = 'example@uproid.com';
  String password = '@Test123';
  DateTime birthday = DateTime.now();
  String permission = 'admin';

  @override
  Future<Map<String, Object?>> toParams({Db? db}) {
    return Future.value({
      'name': name,
      'age': age,
      'email': email,
      'password': password,
      'birthday': birthday.toString(),
      'permission': permission,
    });
  }
}
