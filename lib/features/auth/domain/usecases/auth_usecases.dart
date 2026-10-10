import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../repositories/auth_repository.dart';

class GetAuthStatus extends UseCase<bool, NoParams> {
  final AuthRepository _repo;
  const GetAuthStatus(this._repo);
  @override
  Future<Result<bool>> call(NoParams p) => _repo.isLoggedIn();
}

class LoginUser extends UseCase<Unit, NoParams> {
  final AuthRepository _repo;
  const LoginUser(this._repo);
  @override
  Future<Result<Unit>> call(NoParams p) => _repo.setLoggedIn(true);
}

class LogoutUser extends UseCase<Unit, NoParams> {
  final AuthRepository _repo;
  const LogoutUser(this._repo);
  @override
  Future<Result<Unit>> call(NoParams p) => _repo.setLoggedIn(false);
}
