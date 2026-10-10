import '../../../../core/result.dart';
import '../datasources/settings_local_data_source.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _local;
  const SettingsRepositoryImpl(this._local);

  @override
  Future<Result<AppSettings>> load() async => Result.ok(_local.read());

  @override
  Future<Result<Unit>> save(AppSettings settings) async {
    await _local.write(settings);
    return const Result.ok(unit);
  }
}
