import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  /// 'system' | 'light' | 'dark'
  final String themeMode;
  final String languageCode;
  final Set<String> interests;
  const AppSettings({this.themeMode = 'system', this.languageCode = 'en', this.interests = const {'Movies', 'Anime', 'Gaming', 'Music'}});

  static const allInterests = ['Movies', 'Anime', 'Gaming', 'Music', 'Travel', 'Tech'];

  AppSettings copyWith({String? themeMode, String? languageCode, Set<String>? interests}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
        interests: interests ?? this.interests,
      );

  @override
  List<Object?> get props => [themeMode, languageCode, interests];
}
