import 'package:webapp/src/router/wa_controller.dart';

abstract class WaAuthController<T> extends WaController {
  WaAuthController(super.rq);

  @override
  Future<String> index();

  Future<String> loginPost();

  Future<String> register();

  Future<String> newUser();

  Future<bool> auth();

  Future<bool> checkPermission();

  Future<bool> authApi();

  Future<({bool success, String message, T? user})> checkLogin();

  Future<String> logout();

  void updateAuth(String email, String password, T user);

  void removeAuth();
}

class Permissions {
  static final String none = 'none';
  static final String superAdmin = 'super-admin';
}
