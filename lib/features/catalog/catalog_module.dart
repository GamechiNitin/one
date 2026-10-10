import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/network/api_client.dart';
import '../../core/presentation/ui_notifier.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/catalog_local_data_source.dart';
import 'data/datasources/catalog_remote_data_source.dart';
import 'data/repositories/catalog_repository_impl.dart';
import 'domain/repositories/catalog_repository.dart';
import 'domain/usecases/catalog_usecases.dart';
import 'presentation/bloc/catalog_bloc.dart';
import 'presentation/bloc/library_cubit.dart';
import 'presentation/bloc/player_cubit.dart';
import 'presentation/bloc/reels_cubit.dart';
import '../wallet/domain/repositories/wallet_repository.dart';
import '../wallet/domain/usecases/wallet_usecases.dart';

class CatalogModule extends DiModule {
  const CatalogModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<CatalogRemoteDataSource>(
          () => CatalogRemoteDataSourceImpl(sl<ApiClient>()))
      ..registerLazySingleton<CatalogLocalDataSource>(
          () => CatalogLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<LibraryLocalDataSource>(
          () => LibraryLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<CatalogRepository>(
          () => CatalogRepositoryImpl(sl(), sl()))
      ..registerLazySingleton<LibraryRepository>(
          () => LibraryRepositoryImpl(sl()))
      ..registerLazySingleton(() => GetCatalog(sl()))
      ..registerLazySingleton(() => LoadLibrary(sl()))
      ..registerLazySingleton(() => ToggleMyList(sl()))
      ..registerLazySingleton(() => SaveOffer(sl()))
      ..registerLazySingleton(
          () => UnlockItem(sl<LibraryRepository>(), sl<WalletRepository>()))
      ..registerLazySingleton(
          () => MarkWatched(sl<LibraryRepository>(), sl<WalletRepository>()))
      ..registerLazySingleton(() => CatalogBloc(sl()))
      ..registerLazySingleton(
          () => LibraryCubit(sl(), sl(), sl(), sl(), sl(), sl<UiNotifier>()))
      // Per-screen cubits are factories: one instance per page.
      ..registerFactory(() => PlayerCubit(sl()))
      ..registerFactory(() => ReelsCubit(sl<AwardPoints>()));
  }
}
