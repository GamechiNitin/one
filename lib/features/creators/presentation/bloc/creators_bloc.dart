import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/ui_notifier.dart';
import '../../../../core/usecase.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart' show LoadStatus;
import '../../domain/entities/creator.dart';
import '../../domain/repositories/creators_repository.dart';
import '../../domain/usecases/creators_usecases.dart';

abstract class CreatorsEvent extends Equatable {
  const CreatorsEvent();
  @override
  List<Object?> get props => [];
}

class CreatorsRequested extends CreatorsEvent {
  const CreatorsRequested();
}

class FollowToggled extends CreatorsEvent {
  final String creatorId;
  const FollowToggled(this.creatorId);
  @override
  List<Object?> get props => [creatorId];
}

class OpportunityApplied extends CreatorsEvent {
  final String opportunityId;
  const OpportunityApplied(this.opportunityId);
  @override
  List<Object?> get props => [opportunityId];
}

class CreatorsState extends Equatable {
  final LoadStatus status;
  final CreatorsData data;
  final CreatorPrefs prefs;
  const CreatorsState({this.status = LoadStatus.initial, this.data = const CreatorsData(), this.prefs = const CreatorPrefs()});

  Map<String, Creator> get byId => {for (final c in data.creators) c.id: c};

  CreatorsState copyWith({LoadStatus? status, CreatorsData? data, CreatorPrefs? prefs}) =>
      CreatorsState(status: status ?? this.status, data: data ?? this.data, prefs: prefs ?? this.prefs);

  @override
  List<Object?> get props => [status, data, prefs];
}

class CreatorsBloc extends Bloc<CreatorsEvent, CreatorsState> {
  final GetCreators _get;
  final ToggleFollow _toggle;
  final ApplyToOpportunity _apply;
  final CreatorsRepository _repo;
  final UiNotifier _ui;

  CreatorsBloc(this._get, this._toggle, this._apply, this._repo, this._ui) : super(const CreatorsState()) {
    on<CreatorsRequested>((e, emit) async {
      emit(state.copyWith(status: LoadStatus.loading, prefs: _repo.loadPrefs()));
      final r = await _get(const NoParams());
      r.fold((f) => emit(state.copyWith(status: LoadStatus.failure)), (d) => emit(state.copyWith(status: LoadStatus.success, data: d)));
    });
    on<FollowToggled>((e, emit) async {
      final r = await _toggle(e.creatorId);
      if (!r.isOk) return;
      emit(state.copyWith(prefs: r.value));
      final name = state.data.creator(e.creatorId)?.name;
      if (name != null && r.value.following.contains(e.creatorId)) _ui.show('msg.following', [name]);
    });
    on<OpportunityApplied>((e, emit) async {
      final r = await _apply(e.opportunityId);
      if (r.isOk) emit(state.copyWith(prefs: r.value));
    });
  }
}
