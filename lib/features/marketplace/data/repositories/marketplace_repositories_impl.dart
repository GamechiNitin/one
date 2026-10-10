import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../datasources/marketplace_data_sources.dart';
import '../models/product_mapper.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/marketplace_repositories.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remote;
  final ProductsLocalDataSource _local;
  const ProductsRepositoryImpl(this._remote, this._local);

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final json = await _remote.fetchProducts();
      await _local.writeCache(json);
      return Result.ok(ProductMapper.list(json));
    } on ServerException catch (e) {
      return _cached(ServerFailure(e.message));
    } on NetworkException {
      return _cached(const NetworkFailure());
    }
  }

  Result<List<Product>> _cached(Failure f) {
    final c = _local.readCache();
    return c != null ? Result.ok(ProductMapper.list(c)) : Result.err(f);
  }
}

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _local;
  const CartRepositoryImpl(this._local);

  @override
  Map<String, int> load() => _local.read();

  @override
  Future<Map<String, int>> add(String id) async {
    final cart = {..._local.read()};
    cart[id] = (cart[id] ?? 0) + 1;
    await _local.write(cart);
    return cart;
  }

  @override
  Future<Map<String, int>> decrement(String id) async {
    final cart = {..._local.read()};
    final q = (cart[id] ?? 0) - 1;
    if (q <= 0) {
      cart.remove(id);
    } else {
      cart[id] = q;
    }
    await _local.write(cart);
    return cart;
  }

  @override
  Future<void> clear() => _local.write({});
}
