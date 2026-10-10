import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/network/api_client.dart';
import '../../core/presentation/ui_notifier.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/marketplace_data_sources.dart';
import 'data/repositories/marketplace_repositories_impl.dart';
import 'domain/repositories/marketplace_repositories.dart';
import 'domain/usecases/marketplace_usecases.dart';
import 'presentation/bloc/market_blocs.dart';
import '../wallet/domain/repositories/wallet_repository.dart';

class MarketplaceModule extends DiModule {
  const MarketplaceModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<ProductsRemoteDataSource>(
          () => ProductsRemoteDataSourceImpl(sl<ApiClient>()))
      ..registerLazySingleton<ProductsLocalDataSource>(
          () => ProductsLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<CartLocalDataSource>(
          () => CartLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<ProductsRepository>(
          () => ProductsRepositoryImpl(sl(), sl()))
      ..registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()))
      ..registerLazySingleton(() => GetProducts(sl()))
      ..registerLazySingleton(() => LoadCart(sl()))
      ..registerLazySingleton(() => AddToCart(sl()))
      ..registerLazySingleton(() => DecrementCart(sl()))
      ..registerLazySingleton(() => CheckoutCart(sl<CartRepository>(),
          sl<ProductsRepository>(), sl<WalletRepository>()))
      ..registerLazySingleton(() => MarketBloc(sl()))
      ..registerLazySingleton(
          () => CartBloc(sl(), sl(), sl(), sl(), sl<UiNotifier>()));
  }
}
