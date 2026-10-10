import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/catalog.dart';
import '../../domain/usecases/catalog_usecases.dart';

enum LoadStatus { initial, loading, success, failure }

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
  @override
  List<Object?> get props => [];
}

class CatalogRequested extends CatalogEvent {
  const CatalogRequested();
}

class CatalogState extends Equatable {
  final LoadStatus status;
  final Catalog catalog;
  final Failure? failure;
  const CatalogState({this.status = LoadStatus.initial, this.catalog = const Catalog(), this.failure});

  @override
  List<Object?> get props => [status, catalog, failure];
}

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetCatalog _getCatalog;
  CatalogBloc(this._getCatalog) : super(const CatalogState()) {
    on<CatalogRequested>((event, emit) async {
      emit(CatalogState(status: LoadStatus.loading, catalog: state.catalog));
      final r = await _getCatalog(const NoParams());
      r.fold(
        (f) => emit(CatalogState(status: LoadStatus.failure, catalog: state.catalog, failure: f)),
        (c) => emit(CatalogState(status: LoadStatus.success, catalog: c)),
      );
    });
  }
}
