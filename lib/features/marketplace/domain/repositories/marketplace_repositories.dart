import '../../../../core/result.dart';
import '../entities/product.dart';

abstract class ProductsRepository {
  Future<Result<List<Product>>> getProducts();
}

abstract class CartRepository {
  Map<String, int> load();
  Future<Map<String, int>> add(String productId);
  Future<Map<String, int>> decrement(String productId);
  Future<void> clear();
}
