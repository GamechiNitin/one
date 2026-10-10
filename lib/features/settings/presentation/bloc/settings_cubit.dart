import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecases.dart';

class SettingsCubit extends Cubit<AppSettings> {
  final LoadSettings _load;
  final SaveSettings _save;
  SettingsCubit(this._load, this._save) : super(const AppSettings());

  Future<void> load() async {
    final r = await _load(const NoParams());
    if (r.isOk) emit(r.value);
  }

  Future<void> setTheme(String mode) async {
    final next = state.copyWith(themeMode: mode);
    emit(next);
    await _save(next);
  }

  Future<void> setLanguage(String code) async {
    final next = state.copyWith(languageCode: code);
    emit(next);
    await _save(next);
  }

  Future<void> toggleInterest(String name) async {
    final next = {...state.interests};
    if (!next.add(name)) next.remove(name);
    final updated = state.copyWith(interests: next);
    emit(updated);
    await _save(updated);
  }

  ThemeMode get themeMode => switch (state.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Locale get locale => Locale(state.languageCode);
}
