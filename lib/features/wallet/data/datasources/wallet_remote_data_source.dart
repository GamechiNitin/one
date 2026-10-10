import '../../../../core/network/api_client.dart';

abstract class WalletRemoteDataSource {
  Future<Map<String, dynamic>> fetchCatalog();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient _api;
  const WalletRemoteDataSourceImpl(this._api);
  @override
  Future<Map<String, dynamic>> fetchCatalog() async => (await _api.get('/rewards') as Map).cast<String, dynamic>();
}
