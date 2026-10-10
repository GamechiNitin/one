import '../../../../core/result.dart';
import '../entities/catalog.dart';

abstract class CatalogRepository {
  /// Remote first, falls back to the last cached catalog when offline.
  Future<Result<Catalog>> getCatalog();
}

abstract class LibraryRepository {
  Library load();
  Future<Result<Library>> toggleMyList(String itemId);
  Future<Result<Library>> markOwned(String itemId);
  Future<Result<Library>> saveOffer(String offerId);

  /// Returns true when this is the first time the item was watched.
  Future<Result<bool>> markWatched(String itemId);
}
