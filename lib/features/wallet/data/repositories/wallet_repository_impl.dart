import 'dart:async';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/utils/formatters.dart';
import '../datasources/wallet_local_data_source.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/wallet_mapper.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource _local;
  final WalletRemoteDataSource _remote;
  final _ctrl = StreamController<WalletSnapshot>.broadcast();
  late WalletSnapshot _s;

  WalletRepositoryImpl(this._local, this._remote) {
    _s = _local.readSnapshot() ?? WalletSnapshot.initial;
  }

  @override
  WalletSnapshot get current => _s;

  @override
  Stream<WalletSnapshot> watch() => _ctrl.stream;

  void _emit(WalletSnapshot next) {
    _s = next;
    _local.writeSnapshot(next);
    _ctrl.add(next);
  }

  @override
  Future<Result<WalletCatalog>> getCatalog() async {
    try {
      final json = await _remote.fetchCatalog();
      await _local.cacheCatalog(json);
      return Result.ok(WalletMapper.catalogFromJson(json));
    } on ServerException catch (e) {
      return _cached(ServerFailure(e.message));
    } on NetworkException {
      return _cached(const NetworkFailure());
    }
  }

  Result<WalletCatalog> _cached(Failure f) {
    final c = _local.readCatalog();
    return c != null ? Result.ok(WalletMapper.catalogFromJson(c)) : Result.err(f);
  }

  @override
  Future<Result<Unit>> topUp(int amount) async {
    _emit(_s.copyWith(balance: _s.balance + amount, tx: [..._s.tx, TxEntry('Wallet top-up', '+${rs(amount)}')]));
    return const Result.ok(unit);
  }

  @override
  Future<Result<Unit>> spend(int amount, String reason) async {
    if (_s.balance < amount) return Result.err(InsufficientFundsFailure(amount - _s.balance));
    _emit(_s.copyWith(balance: _s.balance - amount, tx: [..._s.tx, TxEntry(reason, '\u2212${rs(amount)}')]));
    return const Result.ok(unit);
  }

  @override
  Future<Result<Unit>> award(int points, String reason) async {
    _emit(_s.copyWith(points: _s.points + points, tx: [..._s.tx, TxEntry(reason, '+$points pts')]));
    return const Result.ok(unit);
  }

  @override
  Future<Result<Unit>> redeem(Reward reward) async {
    if (_s.points < reward.cost) return Result.err(InsufficientPointsFailure(reward.cost - _s.points));
    _emit(_s.copyWith(points: _s.points - reward.cost, tx: [..._s.tx, TxEntry('Redeemed ${reward.title}', '\u2212${nf(reward.cost)} pts')]));
    return const Result.ok(unit);
  }

  @override
  Future<Result<Unit>> changePlan(Plan plan) async {
    if (_s.plan == plan.name) return const Result.err(ValidationFailure('Already on this plan'));
    if (_s.balance < plan.price) return Result.err(InsufficientFundsFailure(plan.price - _s.balance));
    _emit(_s.copyWith(
      balance: _s.balance - plan.price,
      plan: plan.name,
      tx: [..._s.tx, TxEntry('ONE ${plan.name}', plan.price > 0 ? '\u2212${rs(plan.price)}' : 'Plan changed')],
    ));
    return const Result.ok(unit);
  }

  @override
  Future<Result<Unit>> claimMission() async {
    if (_s.missionDone) return const Result.err(ValidationFailure('Already claimed'));
    _emit(_s.copyWith(missionDone: true, points: _s.points + 50, tx: [..._s.tx, const TxEntry('Daily mission', '+50 pts')]));
    return const Result.ok(unit);
  }

  @override
  Future<Result<Unit>> joinWatchParty() async {
    if (_s.joinedParty) return const Result.err(ValidationFailure('Already joined'));
    _emit(_s.copyWith(joinedParty: true, points: _s.points + 30, tx: [..._s.tx, const TxEntry('Joined a watch party', '+30 pts')]));
    return const Result.ok(unit);
  }

  @override
  Future<Result<Unit>> payBill(int amount) async {
    if (_s.billPaid) return const Result.err(ValidationFailure('Already paid'));
    if (_s.balance < amount) return Result.err(InsufficientFundsFailure(amount - _s.balance));
    _emit(_s.copyWith(
      balance: _s.balance - amount,
      billPaid: true,
      points: _s.points + 50,
      tx: [..._s.tx, TxEntry('Paid monthly bill', '\u2212${rs(amount)}'), const TxEntry('Paid on time', '+50 pts')],
    ));
    return const Result.ok(unit);
  }
}
