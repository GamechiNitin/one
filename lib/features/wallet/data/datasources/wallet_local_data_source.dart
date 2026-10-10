import '../../../../core/storage/key_value_store.dart';
import '../models/wallet_mapper.dart';
import '../../domain/entities/wallet.dart';

/// Source of truth for balance, points, and plan (persisted on device).
abstract class WalletLocalDataSource {
  WalletSnapshot? readSnapshot();
  Future<void> writeSnapshot(WalletSnapshot s);
  Map<String, dynamic>? readCatalog();
  Future<void> cacheCatalog(Map<String, dynamic> json);
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  static const _kSnapshot = 'wallet.snapshot';
  static const _kCatalog = 'wallet.catalog';
  final KeyValueStore _store;
  const WalletLocalDataSourceImpl(this._store);

  @override
  WalletSnapshot? readSnapshot() {
    final j = _store.getJson(_kSnapshot);
    return j is Map ? WalletMapper.snapshotFromJson(j.cast<String, dynamic>()) : null;
  }

  @override
  Future<void> writeSnapshot(WalletSnapshot s) => _store.setJson(_kSnapshot, WalletMapper.snapshotToJson(s));

  @override
  Map<String, dynamic>? readCatalog() {
    final j = _store.getJson(_kCatalog);
    return j is Map ? j.cast<String, dynamic>() : null;
  }

  @override
  Future<void> cacheCatalog(Map<String, dynamic> json) => _store.setJson(_kCatalog, json);
}
