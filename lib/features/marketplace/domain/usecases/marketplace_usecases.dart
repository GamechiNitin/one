import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../entities/product.dart';
import '../repositories/marketplace_repositories.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

class GetProducts extends UseCase<List<Product>, NoParams> {
  final ProductsRepository _repo;
  const GetProducts(this._repo);
  @override
  Future<Result<List<Product>>> call(NoParams p) => _repo.getProducts();
}

class LoadCart {
  final CartRepository _repo;
  const LoadCart(this._repo);
  Map<String, int> call() => _repo.load();
}

class AddToCart extends UseCase<Map<String, int>, String> {
  final CartRepository _repo;
  const AddToCart(this._repo);
  @override
  Future<Result<Map<String, int>>> call(String id) async => Result.ok(await _repo.add(id));
}

class DecrementCart extends UseCase<Map<String, int>, String> {
  final CartRepository _repo;
  const DecrementCart(this._repo);
  @override
  Future<Result<Map<String, int>>> call(String id) async => Result.ok(await _repo.decrement(id));
}

/// Charges the wallet for the cart, awards 1 point per Rs 20, and empties the cart.
class CheckoutCart extends UseCase<CartSummary, NoParams> {
  final CartRepository _cart;
  final ProductsRepository _products;
  final WalletRepository _wallet;
  const CheckoutCart(this._cart, this._products, this._wallet);

  @override
  Future<Result<CartSummary>> call(NoParams p) async {
    final products = await _products.getProducts();
    if (!products.isOk) return Result.err(products.failure!);
    final summary = CartSummary.compute(_cart.load(), products.value, planIsPaid: _wallet.current.isPaid);
    if (summary.total <= 0) return const Result.err(ValidationFailure('Cart is empty'));
    final paid = await _wallet.spend(summary.total, 'Marketplace order');
    if (!paid.isOk) return Result.err(paid.failure!);
    await _wallet.award(summary.points, 'Order points');
    await _cart.clear();
    return Result.ok(summary);
  }
}
