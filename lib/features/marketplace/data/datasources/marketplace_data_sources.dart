import '../../../../core/network/api_client.dart';
import '../../../../core/storage/key_value_store.dart';

abstract class ProductsRemoteDataSource {
  Future<List> fetchProducts();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient _api;
  const ProductsRemoteDataSourceImpl(this._api);
  @override
  Future<List> fetchProducts() async => (await _api.get('/products')) as List;
}

abstract class ProductsLocalDataSource {
  List? readCache();
  Future<void> writeCache(List json);
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final KeyValueStore _store;
  const ProductsLocalDataSourceImpl(this._store);
  @override
  List? readCache() {
    final j = _store.getJson('products.cache');
    return j is List ? j : null;
  }

  @override
  Future<void> writeCache(List json) => _store.setJson('products.cache', json);
}

abstract class CartLocalDataSource {
  Map<String, int> read();
  Future<void> write(Map<String, int> cart);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final KeyValueStore _store;
  const CartLocalDataSourceImpl(this._store);

  @override
  Map<String, int> read() {
    final j = _store.getJson('cart.lines');
    if (j is! Map) return {};
    return j.map((k, v) => MapEntry(k as String, (v as num).toInt()));
  }

  @override
  Future<void> write(Map<String, int> cart) => _store.setJson('cart.lines', cart);
}
