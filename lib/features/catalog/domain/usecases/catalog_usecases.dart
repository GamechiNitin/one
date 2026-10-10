import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../entities/catalog.dart';
import '../repositories/catalog_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

class GetCatalog extends UseCase<Catalog, NoParams> {
  final CatalogRepository _repo;
  const GetCatalog(this._repo);
  @override
  Future<Result<Catalog>> call(NoParams p) => _repo.getCatalog();
}

class LoadLibrary {
  final LibraryRepository _repo;
  const LoadLibrary(this._repo);
  Library call() => _repo.load();
}

class ToggleMyList extends UseCase<Library, String> {
  final LibraryRepository _repo;
  const ToggleMyList(this._repo);
  @override
  Future<Result<Library>> call(String id) => _repo.toggleMyList(id);
}

class SaveOffer extends UseCase<Library, String> {
  final LibraryRepository _repo;
  const SaveOffer(this._repo);
  @override
  Future<Result<Library>> call(String id) => _repo.saveOffer(id);
}

/// Pays for a creator film from the wallet, then adds it to the library.
class UnlockItem extends UseCase<Library, Item> {
  final LibraryRepository _library;
  final WalletRepository _wallet;
  const UnlockItem(this._library, this._wallet);
  @override
  Future<Result<Library>> call(Item item) async {
    if (!item.isPaid) return const Result.err(ValidationFailure('Item is free'));
    final paid = await _wallet.spend(item.price, 'Unlocked ${item.title}');
    if (!paid.isOk) return Result.err(paid.failure!);
    return _library.markOwned(item.id);
  }
}

/// Awards 10 points the first time an item is watched.
class MarkWatched extends UseCase<bool, Item> {
  final LibraryRepository _library;
  final WalletRepository _wallet;
  const MarkWatched(this._library, this._wallet);
  @override
  Future<Result<bool>> call(Item item) async {
    final r = await _library.markWatched(item.id);
    if (r.isOk && r.value) await _wallet.award(10, 'Watched ${item.title}');
    return r;
  }
}
