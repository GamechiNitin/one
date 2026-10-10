import '../../../../core/result.dart';
import '../../../../core/usecase.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

class GetEvents extends UseCase<List<Event>, NoParams> {
  final EventsRepository _repo;
  const GetEvents(this._repo);
  @override
  Future<Result<List<Event>>> call(NoParams p) => _repo.getEvents();
}

class GetTickets {
  final EventsRepository _repo;
  const GetTickets(this._repo);
  List<Ticket> call() => _repo.getTickets();
}

class BookEventParams {
  final Event event;
  final int qty;
  final bool applyPass;
  const BookEventParams(this.event, this.qty, this.applyPass);
}

/// Pays from the wallet, awards points, and stores the ticket.
class BookEvent extends UseCase<Ticket, BookEventParams> {
  final EventsRepository _events;
  final WalletRepository _wallet;
  const BookEvent(this._events, this._wallet);

  @override
  Future<Result<Ticket>> call(BookEventParams p) async {
    final quote = EventQuote.of(p.event, qty: p.qty, applyPass: p.applyPass, planIsPaid: _wallet.current.isPaid);
    final paid = await _wallet.spend(quote.total, 'Booked ${p.event.title}');
    if (!paid.isOk) return Result.err(paid.failure!);
    await _wallet.award(quote.points, 'Event points');
    final n = _events.getTickets().length + 1;
    final ticket = Ticket(id: 'ON${1000 + n * 7}', eventId: p.event.id, qty: p.qty, total: quote.total, seed: n + 3);
    await _events.saveTicket(ticket);
    return Result.ok(ticket);
  }
}
