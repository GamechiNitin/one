import 'package:get_it/get_it.dart';
import '../../core/di/di_module.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/key_value_store.dart';
import 'data/datasources/wallet_local_data_source.dart';
import 'data/datasources/wallet_remote_data_source.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'domain/repositories/wallet_repository.dart';
import 'domain/usecases/wallet_usecases.dart';
import 'presentation/bloc/wallet_bloc.dart';
import '../../core/presentation/ui_notifier.dart';

class WalletModule extends DiModule {
  const WalletModule();
  @override
  void register(GetIt sl) {
    sl
      ..registerLazySingleton<WalletRemoteDataSource>(
          () => WalletRemoteDataSourceImpl(sl<ApiClient>()))
      ..registerLazySingleton<WalletLocalDataSource>(
          () => WalletLocalDataSourceImpl(sl<KeyValueStore>()))
      ..registerLazySingleton<WalletRepository>(
          () => WalletRepositoryImpl(sl(), sl()))
      ..registerLazySingleton(() => GetWalletCatalog(sl()))
      ..registerLazySingleton(() => TopUpWallet(sl()))
      ..registerLazySingleton(() => RedeemReward(sl()))
      ..registerLazySingleton(() => AwardPoints(sl()))
      ..registerLazySingleton(() => ChangePlan(sl()))
      ..registerLazySingleton(() => ClaimDailyMission(sl()))
      ..registerLazySingleton(() => JoinWatchParty(sl()))
      ..registerLazySingleton(() => WalletBloc(
          sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl<UiNotifier>()));
  }
}
