import '../../../../core/storage/key_value_store.dart';

abstract class AuthLocalDataSource {
  bool isLoggedIn();
  Future<void> setLoggedIn(bool value);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _k = 'auth.loggedIn';
  final KeyValueStore _store;
  const AuthLocalDataSourceImpl(this._store);
  @override
  bool isLoggedIn() => _store.getString(_k) == '1';
  @override
  Future<void> setLoggedIn(bool value) => _store.setString(_k, value ? '1' : '0');
}
