import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class GetWalletCatalog extends UseCase<WalletCatalog, NoParams> {
  final WalletRepository _repo;
  const GetWalletCatalog(this._repo);
  @override
  Future<Result<WalletCatalog>> call(NoParams p) => _repo.getCatalog();
}

class TopUpWallet extends UseCase<Unit, int> {
  final WalletRepository _repo;
  const TopUpWallet(this._repo);
  @override
  Future<Result<Unit>> call(int amount) => _repo.topUp(amount);
}

class RedeemReward extends UseCase<Unit, Reward> {
  final WalletRepository _repo;
  const RedeemReward(this._repo);
  @override
  Future<Result<Unit>> call(Reward r) => _repo.redeem(r);
}

class AwardPointsParams {
  final int points;
  final String reason;
  const AwardPointsParams(this.points, this.reason);
}

class AwardPoints extends UseCase<Unit, AwardPointsParams> {
  final WalletRepository _repo;
  const AwardPoints(this._repo);
  @override
  Future<Result<Unit>> call(AwardPointsParams p) => _repo.award(p.points, p.reason);
}

class ChangePlan extends UseCase<Unit, Plan> {
  final WalletRepository _repo;
  const ChangePlan(this._repo);
  @override
  Future<Result<Unit>> call(Plan plan) => _repo.changePlan(plan);
}

class ClaimDailyMission extends UseCase<Unit, NoParams> {
  final WalletRepository _repo;
  const ClaimDailyMission(this._repo);
  @override
  Future<Result<Unit>> call(NoParams p) => _repo.claimMission();
}

class JoinWatchParty extends UseCase<Unit, NoParams> {
  final WalletRepository _repo;
  const JoinWatchParty(this._repo);
  @override
  Future<Result<Unit>> call(NoParams p) => _repo.joinWatchParty();
}
