import 'package:get_it/get_it.dart';

/// A feature registers its own data sources, repositories, use cases and blocs.
abstract class DiModule {
  const DiModule();
  void register(GetIt sl);
}
