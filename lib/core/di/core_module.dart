import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'di_module.dart';
import '../network/api_client.dart';
import '../network/mock_backend.dart';
import '../presentation/ui_notifier.dart';
import '../storage/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared infrastructure: storage, networking, and the UI message bus.
class CoreModule extends DiModule {
  final SharedPreferences prefs;
  const CoreModule(this.prefs);

  @override
  void register(GetIt sl) {
    sl
      ..registerSingleton<KeyValueStore>(KeyValueStore(prefs))
      ..registerLazySingleton<UiNotifier>(UiNotifier.new)
      ..registerLazySingleton<http.Client>(http.Client.new)
      ..registerLazySingleton<MockBackend>(MockBackend.new)
      ..registerLazySingleton<ApiClient>(
        () => AppConfig.useMockApi
            ? MockApiClient(sl<MockBackend>())
            : HttpApiClient(sl<http.Client>()),
      );
  }
}
