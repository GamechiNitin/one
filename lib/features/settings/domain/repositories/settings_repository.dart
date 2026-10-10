import '../../../../core/result.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Result<AppSettings>> load();
  Future<Result<Unit>> save(AppSettings settings);
}
