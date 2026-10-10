import '../../../../core/network/api_client.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/creator.dart';

abstract class CreatorsRemoteDataSource {
  Future<Map<String, dynamic>> fetchCreators();
}

class CreatorsRemoteDataSourceImpl implements CreatorsRemoteDataSource {
  final ApiClient _api;
  const CreatorsRemoteDataSourceImpl(this._api);
  @override
  Future<Map<String, dynamic>> fetchCreators() async => (await _api.get('/creators') as Map).cast<String, dynamic>();
}

abstract class CreatorsLocalDataSource {
  Map<String, dynamic>? readCache();
  Future<void> writeCache(Map<String, dynamic> json);
  CreatorPrefs readPrefs();
  Future<void> writePrefs(CreatorPrefs p);
}

class CreatorsLocalDataSourceImpl implements CreatorsLocalDataSource {
  final KeyValueStore _store;
  const CreatorsLocalDataSourceImpl(this._store);

  @override
  Map<String, dynamic>? readCache() {
    final j = _store.getJson('creators.cache');
    return j is Map ? j.cast<String, dynamic>() : null;
  }

  @override
  Future<void> writeCache(Map<String, dynamic> json) => _store.setJson('creators.cache', json);

  @override
  CreatorPrefs readPrefs() {
    final hasFollowing = _store.getString('creators.seeded') != null;
    return CreatorPrefs(
      following: hasFollowing ? _store.getStringList('creators.following').toSet() : {'aarav'},
      applied: _store.getStringList('creators.applied').toSet(),
    );
  }

  @override
  Future<void> writePrefs(CreatorPrefs p) async {
    await _store.setString('creators.seeded', '1');
    await _store.setStringList('creators.following', p.following.toList());
    await _store.setStringList('creators.applied', p.applied.toList());
  }
}
