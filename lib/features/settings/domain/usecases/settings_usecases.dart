import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class LoadSettings extends UseCase<AppSettings, NoParams> {
  final SettingsRepository _repo;
  const LoadSettings(this._repo);
  @override
  Future<Result<AppSettings>> call(NoParams p) => _repo.load();
}

class SaveSettings extends UseCase<Unit, AppSettings> {
  final SettingsRepository _repo;
  const SaveSettings(this._repo);
  @override
  Future<Result<Unit>> call(AppSettings s) => _repo.save(s);
}
