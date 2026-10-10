import '../../../../core/network/api_client.dart';

abstract class CatalogRemoteDataSource {
  Future<Map<String, dynamic>> fetchCatalog();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final ApiClient _api;
  const CatalogRemoteDataSourceImpl(this._api);
  @override
  Future<Map<String, dynamic>> fetchCatalog() async => (await _api.get('/catalog') as Map).cast<String, dynamic>();
}
