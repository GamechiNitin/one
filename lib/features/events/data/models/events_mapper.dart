import '../../../../core/domain/art.dart';
import '../../domain/entities/event.dart';

class EventsMapper {
  EventsMapper._();

  static Event event(Map<String, dynamic> j) => Event(
        id: j['id'] as String,
        title: j['title'] as String,
        cat: j['cat'] as String,
        venue: j['venue'] as String,
        when: j['when'] as String,
        price: (j['price'] as num).toInt(),
        art: Art.fromJson((j['art'] as Map).cast<String, dynamic>()),
        friends: (j['friends'] as List).map((e) => e as String).toList(),
        offer: j['offer'] as String,
        up: j['up'] as String,
        creator: j['creator'] as String?,
      );

  static List<Event> events(List raw) => raw.map((e) => event((e as Map).cast<String, dynamic>())).toList();

  static Map<String, dynamic> ticketToJson(Ticket t) => {'id': t.id, 'eventId': t.eventId, 'qty': t.qty, 'total': t.total, 'seed': t.seed};

  static Ticket ticket(Map<String, dynamic> j) => Ticket(
        id: j['id'] as String,
        eventId: j['eventId'] as String,
        qty: (j['qty'] as num).toInt(),
        total: (j['total'] as num).toInt(),
        seed: (j['seed'] as num).toInt(),
      );
}
