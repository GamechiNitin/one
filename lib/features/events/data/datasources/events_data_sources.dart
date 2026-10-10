import '../../../../core/network/api_client.dart';
import '../../../../core/storage/key_value_store.dart';

abstract class EventsRemoteDataSource {
  Future<List> fetchEvents();
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final ApiClient _api;
  const EventsRemoteDataSourceImpl(this._api);
  @override
  Future<List> fetchEvents() async => (await _api.get('/events')) as List;
}

abstract class EventsLocalDataSource {
  List? readCache();
  Future<void> writeCache(List json);
  List readTickets();
  Future<void> writeTickets(List json);
}

class EventsLocalDataSourceImpl implements EventsLocalDataSource {
  final KeyValueStore _store;
  const EventsLocalDataSourceImpl(this._store);

  @override
  List? readCache() {
    final j = _store.getJson('events.cache');
    return j is List ? j : null;
  }

  @override
  Future<void> writeCache(List json) => _store.setJson('events.cache', json);

  @override
  List readTickets() {
    final j = _store.getJson('events.tickets');
    return j is List ? j : const [];
  }

  @override
  Future<void> writeTickets(List json) => _store.setJson('events.tickets', json);
}
