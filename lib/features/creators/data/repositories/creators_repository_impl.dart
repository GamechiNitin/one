import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../datasources/creators_data_sources.dart';
import '../models/creators_mapper.dart';
import '../../domain/entities/creator.dart';
import '../../domain/repositories/creators_repository.dart';

class CreatorsRepositoryImpl implements CreatorsRepository {
  final CreatorsRemoteDataSource _remote;
  final CreatorsLocalDataSource _local;
  const CreatorsRepositoryImpl(this._remote, this._local);

  @override
  Future<Result<CreatorsData>> getCreators() async {
    try {
      final json = await _remote.fetchCreators();
      await _local.writeCache(json);
      return Result.ok(CreatorsMapper.fromJson(json));
    } on ServerException catch (e) {
      return _cached(ServerFailure(e.message));
    } on NetworkException {
      return _cached(const NetworkFailure());
    }
  }

  Result<CreatorsData> _cached(Failure f) {
    final c = _local.readCache();
    return c != null ? Result.ok(CreatorsMapper.fromJson(c)) : Result.err(f);
  }

  @override
  CreatorPrefs loadPrefs() => _local.readPrefs();

  @override
  Future<CreatorPrefs> toggleFollow(String id) async {
    final p = _local.readPrefs();
    final next = {...p.following};
    if (!next.add(id)) next.remove(id);
    final updated = p.copyWith(following: next);
    await _local.writePrefs(updated);
    return updated;
  }

  @override
  Future<bool> markApplied(String id) async {
    final p = _local.readPrefs();
    if (p.applied.contains(id)) return false;
    await _local.writePrefs(p.copyWith(applied: {...p.applied, id}));
    return true;
  }
}
