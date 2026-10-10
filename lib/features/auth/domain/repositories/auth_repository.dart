import '../../../../core/result.dart';

abstract class AuthRepository {
  Future<Result<bool>> isLoggedIn();
  Future<Result<Unit>> setLoggedIn(bool value);
}
