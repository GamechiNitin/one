import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/assistant_data_sources.dart';
import 'data/repositories/assistant_repository_impl.dart';
import 'domain/repositories/assistant_repository.dart';
import 'domain/usecases/assistant_usecases.dart';
import 'presentation/bloc/assistant_bloc.dart';
import '../wallet/domain/repositories/wallet_repository.dart';

class AssistantModule extends DiModule {
  const AssistantModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<AssistantRemoteDataSource>(
          () => AssistantRemoteDataSourceImpl(sl<ApiClient>()))
      ..registerLazySingleton<AssistantLocalDataSource>(
          () => AssistantLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<AssistantRepository>(
          () => AssistantRepositoryImpl(sl(), sl()))
      ..registerLazySingleton(() => SendAssistantMessage(
          sl<AssistantRepository>(), sl<WalletRepository>()))
      ..registerLazySingleton(() => RunAssistantAction(sl<WalletRepository>()))
      ..registerLazySingleton(
          () => AssistantBloc(sl(), sl(), sl<AssistantRepository>()));
  }
}
