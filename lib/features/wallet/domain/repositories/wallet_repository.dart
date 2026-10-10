import '../../../../core/result.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  WalletSnapshot get current;
  Stream<WalletSnapshot> watch();
  Future<Result<WalletCatalog>> getCatalog();
  Future<Result<Unit>> topUp(int amount);

  /// Debits the wallet. Fails with [InsufficientFundsFailure].
  Future<Result<Unit>> spend(int amount, String reason);
  Future<Result<Unit>> award(int points, String reason);
  Future<Result<Unit>> redeem(Reward reward);
  Future<Result<Unit>> changePlan(Plan plan);
  Future<Result<Unit>> claimMission();
  Future<Result<Unit>> joinWatchParty();
  Future<Result<Unit>> payBill(int amount);
}
