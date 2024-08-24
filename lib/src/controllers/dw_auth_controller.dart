import 'package:dweb/src/router/dw_controller.dart';

abstract class DwAuthController<T> extends DwController {
  DwAuthController(super.rq);

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
