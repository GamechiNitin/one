import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/settings_local_data_source.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/settings_usecases.dart';
import 'presentation/bloc/settings_cubit.dart';

class SettingsModule extends DiModule {
  const SettingsModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<SettingsLocalDataSource>(
          () => SettingsLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<SettingsRepository>(
          () => SettingsRepositoryImpl(sl()))
      ..registerLazySingleton(() => LoadSettings(sl()))
      ..registerLazySingleton(() => SaveSettings(sl()))
      ..registerLazySingleton(() => SettingsCubit(sl(), sl()));
  }
}
