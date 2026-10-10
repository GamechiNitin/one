import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/app_settings.dart';

abstract class SettingsLocalDataSource {
  AppSettings read();
  Future<void> write(AppSettings s);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final KeyValueStore _store;
  const SettingsLocalDataSourceImpl(this._store);

  @override
  AppSettings read() => AppSettings(
        themeMode: _store.getString('settings.theme') ?? 'system',
        languageCode: _store.getString('settings.lang') ?? 'en',
        interests: _store.getString('settings.interestsSet') == null ? const {'Movies', 'Anime', 'Gaming', 'Music'} : _store.getStringList('settings.interests').toSet(),
      );

  @override
  Future<void> write(AppSettings s) async {
    await _store.setString('settings.theme', s.themeMode);
    await _store.setString('settings.lang', s.languageCode);
    await _store.setString('settings.interestsSet', '1');
    await _store.setStringList('settings.interests', s.interests.toList());
  }
}
