import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/network/api_client.dart';
import '../../core/presentation/ui_notifier.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/events_data_sources.dart';
import 'data/repositories/events_repository_impl.dart';
import 'domain/repositories/events_repository.dart';
import 'domain/usecases/events_usecases.dart';
import 'presentation/bloc/events_bloc.dart';
import '../wallet/domain/repositories/wallet_repository.dart';

class EventsModule extends DiModule {
  const EventsModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<EventsRemoteDataSource>(
          () => EventsRemoteDataSourceImpl(sl<ApiClient>()))
      ..registerLazySingleton<EventsLocalDataSource>(
          () => EventsLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<EventsRepository>(
          () => EventsRepositoryImpl(sl(), sl()))
      ..registerLazySingleton(() => GetEvents(sl()))
      ..registerLazySingleton(() => GetTickets(sl()))
      ..registerLazySingleton(
          () => BookEvent(sl<EventsRepository>(), sl<WalletRepository>()))
      ..registerLazySingleton(
          () => EventsBloc(sl(), sl(), sl(), sl<UiNotifier>()));
  }
}
