import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../datasources/catalog_local_data_source.dart';
import '../datasources/catalog_remote_data_source.dart';
import '../models/catalog_mapper.dart';
import '../../domain/entities/catalog.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remote;
  final CatalogLocalDataSource _local;
  const CatalogRepositoryImpl(this._remote, this._local);

  @override
  Future<Result<Catalog>> getCatalog() async {
    try {
      final json = await _remote.fetchCatalog();
      await _local.cacheCatalog(json);
      return Result.ok(CatalogMapper.catalog(json));
    } on ServerException catch (e) {
      return _fromCache(ServerFailure(e.message));
    } on NetworkException {
      return _fromCache(const NetworkFailure());
    }
  }

  Result<Catalog> _fromCache(Failure failure) {
    final cached = _local.readCachedCatalog();
    return cached != null ? Result.ok(CatalogMapper.catalog(cached)) : Result.err(failure);
  }
}

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource _local;
  const LibraryRepositoryImpl(this._local);

  @override
  Library load() => _local.read();

  Future<Result<Library>> _save(Library l) async {
    await _local.write(l);
    return Result.ok(l);
  }

  @override
  Future<Result<Library>> toggleMyList(String id) {
    final l = _local.read();
    final next = {...l.myList};
    if (!next.add(id)) next.remove(id);
    return _save(l.copyWith(myList: next));
  }

  @override
  Future<Result<Library>> markOwned(String id) {
    final l = _local.read();
    return _save(l.copyWith(owned: {...l.owned, id}));
  }

  @override
  Future<Result<Library>> saveOffer(String id) {
    final l = _local.read();
    return _save(l.copyWith(savedOffers: {...l.savedOffers, id}));
  }

  @override
  Future<Result<bool>> markWatched(String id) async {
    final l = _local.read();
    if (l.watched.contains(id)) return const Result.ok(false);
    await _local.write(l.copyWith(watched: {...l.watched, id}));
    return const Result.ok(true);
  }
}
