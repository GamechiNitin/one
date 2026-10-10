import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/presentation/ui_notifier.dart';
import '../../../../core/usecase.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart' show LoadStatus;
import '../../domain/entities/product.dart';
import '../../domain/usecases/marketplace_usecases.dart';

// ======================= MarketBloc (product list + filters) =======================
abstract class MarketEvent extends Equatable {
  const MarketEvent();
  @override
  List<Object?> get props => [];
}

class MarketRequested extends MarketEvent {
  const MarketRequested();
}

class MarketCategoryChanged extends MarketEvent {
  final String category;
  const MarketCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class MarketBrandChanged extends MarketEvent {
  final String? brand;
  const MarketBrandChanged(this.brand);
  @override
  List<Object?> get props => [brand];
}

class MarketState extends Equatable {
  final LoadStatus status;
  final List<Product> products;
  final String category;
  final String? brand;
  const MarketState({this.status = LoadStatus.initial, this.products = const [], this.category = 'All', this.brand});

  List<Product> get visible => products.where((p) => (category == 'All' || p.cat == category) && (brand == null || p.brand == brand)).toList();

  Product? product(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  MarketState copyWith({LoadStatus? status, List<Product>? products, String? category, String? brand, bool clearBrand = false}) => MarketState(
        status: status ?? this.status,
        products: products ?? this.products,
        category: category ?? this.category,
        brand: clearBrand ? null : (brand ?? this.brand),
      );

  @override
  List<Object?> get props => [status, products, category, brand];
}

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetProducts _get;
  MarketBloc(this._get) : super(const MarketState()) {
    on<MarketRequested>((e, emit) async {
      emit(state.copyWith(status: LoadStatus.loading));
      final r = await _get(const NoParams());
      r.fold((f) => emit(state.copyWith(status: LoadStatus.failure)), (p) => emit(state.copyWith(status: LoadStatus.success, products: p)));
    });
    on<MarketCategoryChanged>((e, emit) => emit(state.copyWith(category: e.category)));
    on<MarketBrandChanged>((e, emit) => emit(state.copyWith(brand: e.brand, clearBrand: e.brand == null, category: 'All')));
  }
}

// ======================= CartBloc =======================
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartItemAdded extends CartEvent {
  final String productId;
  final bool silent;
  const CartItemAdded(this.productId, {this.silent = false});
  @override
  List<Object?> get props => [productId, silent];
}

class CartItemRemoved extends CartEvent {
  final String productId;
  const CartItemRemoved(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartCheckoutRequested extends CartEvent {
  const CartCheckoutRequested();
}

enum CheckoutStatus { idle, success, failure }

class CartState extends Equatable {
  final Map<String, int> lines;
  final CheckoutStatus checkout;
  const CartState({this.lines = const {}, this.checkout = CheckoutStatus.idle});

  int get count => lines.values.fold(0, (a, b) => a + b);

  @override
  List<Object?> get props => [lines, checkout];
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final LoadCart _load;
  final AddToCart _add;
  final DecrementCart _dec;
  final CheckoutCart _checkout;
  final UiNotifier _ui;

  CartBloc(this._load, this._add, this._dec, this._checkout, this._ui) : super(const CartState()) {
    on<CartStarted>((e, emit) => emit(CartState(lines: _load())));
    on<CartItemAdded>((e, emit) async {
      final r = await _add(e.productId);
      if (r.isOk) emit(CartState(lines: r.value));
      if (!e.silent) _ui.show('msg.addedToCart');
    });
    on<CartItemRemoved>((e, emit) async {
      final r = await _dec(e.productId);
      if (r.isOk) emit(CartState(lines: r.value));
    });
    on<CartCheckoutRequested>((e, emit) async {
      final r = await _checkout(const NoParams());
      r.fold(
        (f) {
          _ui.show(f is InsufficientFundsFailure ? 'msg.lowBalance' : 'msg.error');
          emit(CartState(lines: state.lines, checkout: CheckoutStatus.failure));
        },
        (summary) {
          _ui.show('msg.orderPlaced', [summary.points]);
          emit(const CartState(lines: {}, checkout: CheckoutStatus.success));
        },
      );
    });
  }
}
