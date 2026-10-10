import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../datasources/events_data_sources.dart';
import '../models/events_mapper.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource _remote;
  final EventsLocalDataSource _local;
  const EventsRepositoryImpl(this._remote, this._local);

  @override
  Future<Result<List<Event>>> getEvents() async {
    try {
      final json = await _remote.fetchEvents();
      await _local.writeCache(json);
      return Result.ok(EventsMapper.events(json));
    } on ServerException catch (e) {
      return _cached(ServerFailure(e.message));
    } on NetworkException {
      return _cached(const NetworkFailure());
    }
  }

  Result<List<Event>> _cached(Failure f) {
    final c = _local.readCache();
    return c != null ? Result.ok(EventsMapper.events(c)) : Result.err(f);
  }

  @override
  List<Ticket> getTickets() =>
      _local.readTickets().map((e) => EventsMapper.ticket((e as Map).cast<String, dynamic>())).toList();

  @override
  Future<void> saveTicket(Ticket t) async {
    final all = [..._local.readTickets(), EventsMapper.ticketToJson(t)];
    await _local.writeTickets(all);
  }
}
