import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth_usecases.dart';
import 'presentation/bloc/auth_cubit.dart';

class AuthModule extends DiModule {
  const AuthModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<AuthLocalDataSource>(
          () => AuthLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
      ..registerLazySingleton(() => GetAuthStatus(sl()))
      ..registerLazySingleton(() => LoginUser(sl()))
      ..registerLazySingleton(() => LogoutUser(sl()))
      ..registerLazySingleton(() => AuthCubit(sl(), sl(), sl()));
  }
}
