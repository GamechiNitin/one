import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../entities/creator.dart';
import '../repositories/creators_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

class GetCreators extends UseCase<CreatorsData, NoParams> {
  final CreatorsRepository _repo;
  const GetCreators(this._repo);
  @override
  Future<Result<CreatorsData>> call(NoParams p) => _repo.getCreators();
}

class ToggleFollow extends UseCase<CreatorPrefs, String> {
  final CreatorsRepository _repo;
  const ToggleFollow(this._repo);
  @override
  Future<Result<CreatorPrefs>> call(String id) async => Result.ok(await _repo.toggleFollow(id));
}

/// Applies to an opportunity and awards 30 points on the first application.
class ApplyToOpportunity extends UseCase<CreatorPrefs, String> {
  final CreatorsRepository _repo;
  final WalletRepository _wallet;
  const ApplyToOpportunity(this._repo, this._wallet);
  @override
  Future<Result<CreatorPrefs>> call(String opportunityId) async {
    final first = await _repo.markApplied(opportunityId);
    if (first) await _wallet.award(30, 'Applied to an opportunity');
    return Result.ok(_repo.loadPrefs());
  }
}
