import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/network/api_client.dart';
import '../../core/presentation/ui_notifier.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/creators_data_sources.dart';
import 'data/repositories/creators_repository_impl.dart';
import 'domain/repositories/creators_repository.dart';
import 'domain/usecases/creators_usecases.dart';
import 'presentation/bloc/creators_bloc.dart';
import '../wallet/domain/repositories/wallet_repository.dart';

class CreatorsModule extends DiModule {
  const CreatorsModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<CreatorsRemoteDataSource>(
          () => CreatorsRemoteDataSourceImpl(sl<ApiClient>()))
      ..registerLazySingleton<CreatorsLocalDataSource>(
          () => CreatorsLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<CreatorsRepository>(
          () => CreatorsRepositoryImpl(sl(), sl()))
      ..registerLazySingleton(() => GetCreators(sl()))
      ..registerLazySingleton(() => ToggleFollow(sl()))
      ..registerLazySingleton(() =>
          ApplyToOpportunity(sl<CreatorsRepository>(), sl<WalletRepository>()))
      ..registerLazySingleton(() => CreatorsBloc(
          sl(), sl(), sl(), sl<CreatorsRepository>(), sl<UiNotifier>()));
  }
}
