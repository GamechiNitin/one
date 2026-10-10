import '../../../../core/network/api_client.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/chat.dart';

abstract class AssistantRemoteDataSource {
  Future<Map<String, dynamic>> chat(String text, AssistantContext ctx);
}

class AssistantRemoteDataSourceImpl implements AssistantRemoteDataSource {
  final ApiClient _api;
  const AssistantRemoteDataSourceImpl(this._api);

  @override
  Future<Map<String, dynamic>> chat(String text, AssistantContext ctx) async {
    final r = await _api.post('/assistant/chat', body: {
      'text': text,
      'context': {'wallet': ctx.wallet, 'points': ctx.points, 'plan': ctx.plan, 'billPaid': ctx.billPaid},
    });
    return (r as Map).cast<String, dynamic>();
  }
}

abstract class AssistantLocalDataSource {
  List readHistory();
  Future<void> writeHistory(List json);
  Future<void> clear();
}

class AssistantLocalDataSourceImpl implements AssistantLocalDataSource {
  static const _k = 'assistant.history';
  final KeyValueStore _store;
  const AssistantLocalDataSourceImpl(this._store);

  @override
  List readHistory() {
    final j = _store.getJson(_k);
    return j is List ? j : const [];
  }

  @override
  Future<void> writeHistory(List json) => _store.setJson(_k, json);

  @override
  Future<void> clear() => _store.remove(_k);
}
