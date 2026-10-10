import '../../../../core/result.dart';
import '../datasources/auth_local_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _local;
  const AuthRepositoryImpl(this._local);

  @override
  Future<Result<bool>> isLoggedIn() async => Result.ok(_local.isLoggedIn());

  @override
  Future<Result<Unit>> setLoggedIn(bool value) async {
    await _local.setLoggedIn(value);
    return const Result.ok(unit);
  }
}
