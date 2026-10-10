import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthState extends Equatable {
  final bool loggedIn;
  const AuthState({this.loggedIn = false});
  @override
  List<Object?> get props => [loggedIn];
}

class AuthCubit extends Cubit<AuthState> {
  final GetAuthStatus _status;
  final LoginUser _login;
  final LogoutUser _logout;
  AuthCubit(this._status, this._login, this._logout) : super(const AuthState());

  Future<void> load() async {
    final r = await _status(const NoParams());
    emit(AuthState(loggedIn: r.isOk && r.value));
  }

  Future<void> login() async {
    await _login(const NoParams());
    emit(const AuthState(loggedIn: true));
  }

  Future<void> logout() async {
    await _logout(const NoParams());
    emit(const AuthState(loggedIn: false));
  }
}
