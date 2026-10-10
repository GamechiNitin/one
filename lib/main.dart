import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Load persisted auth + settings before the first frame so the router redirect and theme are correct.
  await sl<AuthCubit>().load();
  await sl<SettingsCubit>().load();
  runApp(const OneApp());
}
