import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/presentation/ui_notifier.dart';
import '../../../../core/usecase.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/wallet_usecases.dart';

// ---- events ----
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class WalletStarted extends WalletEvent {
  const WalletStarted();
}

class WalletTopUpRequested extends WalletEvent {
  const WalletTopUpRequested();
}

class WalletRedeemRequested extends WalletEvent {
  final Reward reward;
  const WalletRedeemRequested(this.reward);
  @override
  List<Object?> get props => [reward];
}

class WalletMissionClaimed extends WalletEvent {
  const WalletMissionClaimed();
}

class WalletPartyJoined extends WalletEvent {
  const WalletPartyJoined();
}

class WalletPlanSelected extends WalletEvent {
  final Plan plan;
  const WalletPlanSelected(this.plan);
  @override
  List<Object?> get props => [plan];
}

class _WalletChanged extends WalletEvent {
  final WalletSnapshot snapshot;
  const _WalletChanged(this.snapshot);
  @override
  List<Object?> get props => [snapshot];
}

// ---- state ----
class WalletState extends Equatable {
  final WalletSnapshot wallet;
  final WalletCatalog catalog;
  const WalletState({required this.wallet, this.catalog = const WalletCatalog([], [])});

  WalletState copyWith({WalletSnapshot? wallet, WalletCatalog? catalog}) =>
      WalletState(wallet: wallet ?? this.wallet, catalog: catalog ?? this.catalog);

  @override
  List<Object?> get props => [wallet, catalog];
}

// ---- bloc ----
/// Mirrors the wallet repository stream into UI state and announces point gains.
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _repo;
  final GetWalletCatalog _getCatalog;
  final TopUpWallet _topUp;
  final RedeemReward _redeem;
  final ClaimDailyMission _mission;
  final JoinWatchParty _party;
  final ChangePlan _changePlan;
  final UiNotifier _ui;
  StreamSubscription<WalletSnapshot>? _sub;

  WalletBloc(this._repo, this._getCatalog, this._topUp, this._redeem, this._mission, this._party, this._changePlan, this._ui)
      : super(WalletState(wallet: _repo.current)) {
    on<WalletStarted>(_onStarted);
    on<_WalletChanged>(_onChanged);
    on<WalletTopUpRequested>((e, emit) async {
      await _topUp(1000);
      _ui.show('msg.topUp', [rs(1000)]);
    });
    on<WalletRedeemRequested>((e, emit) async {
      final r = await _redeem(e.reward);
      r.fold(
        (f) => _ui.show('msg.needPoints', [f is InsufficientPointsFailure ? nf(f.shortBy) : '']),
        (_) => _ui.show('msg.redeemed', [e.reward.title]),
      );
    });
    on<WalletMissionClaimed>((e, emit) async => _mission(const NoParams()));
    on<WalletPartyJoined>((e, emit) async => _party(const NoParams()));
    on<WalletPlanSelected>((e, emit) async {
      final r = await _changePlan(e.plan);
      r.fold(
        (f) {
          if (f is InsufficientFundsFailure) _ui.show('msg.lowBalance');
        },
        (_) => _ui.show('msg.planChanged', [e.plan.name]),
      );
    });
  }

  Future<void> _onStarted(WalletStarted e, Emitter<WalletState> emit) async {
    _sub ??= _repo.watch().listen((s) => add(_WalletChanged(s)));
    final r = await _getCatalog(const NoParams());
    r.fold((_) {}, (c) => emit(state.copyWith(catalog: c, wallet: _repo.current)));
  }

  void _onChanged(_WalletChanged e, Emitter<WalletState> emit) {
    final gained = e.snapshot.points - state.wallet.points;
    if (gained > 0) _ui.show('msg.points', [gained]);
    emit(state.copyWith(wallet: e.snapshot));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
