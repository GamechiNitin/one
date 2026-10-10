import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/catalog.dart';

abstract class CatalogLocalDataSource {
  Map<String, dynamic>? readCachedCatalog();
  Future<void> cacheCatalog(Map<String, dynamic> json);
}

class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  static const _k = 'catalog.cache';
  final KeyValueStore _store;
  const CatalogLocalDataSourceImpl(this._store);

  @override
  Map<String, dynamic>? readCachedCatalog() {
    final j = _store.getJson(_k);
    return j is Map ? j.cast<String, dynamic>() : null;
  }

  @override
  Future<void> cacheCatalog(Map<String, dynamic> json) => _store.setJson(_k, json);
}

/// Per-user library: my list, unlocked films, and watched items.
abstract class LibraryLocalDataSource {
  Library read();
  Future<void> write(Library l);
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final KeyValueStore _store;
  const LibraryLocalDataSourceImpl(this._store);

  @override
  Library read() => Library(
        myList: _store.getStringList('library.myList').toSet(),
        owned: _store.getStringList('library.owned').toSet(),
        watched: _store.getStringList('library.watched').toSet(),
        savedOffers: _store.getStringList('library.offers').toSet(),
      );

  @override
  Future<void> write(Library l) async {
    await _store.setStringList('library.myList', l.myList.toList());
    await _store.setStringList('library.owned', l.owned.toList());
    await _store.setStringList('library.watched', l.watched.toList());
    await _store.setStringList('library.offers', l.savedOffers.toList());
  }
}
