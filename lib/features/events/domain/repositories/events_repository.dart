import '../../../../core/result.dart';
import '../entities/event.dart';

abstract class EventsRepository {
  Future<Result<List<Event>>> getEvents();
  List<Ticket> getTickets();
  Future<void> saveTicket(Ticket ticket);
}
