import 'package:equatable/equatable.dart';
import '../../../../core/domain/art.dart';

class Event extends Equatable {
  final String id, title, cat, venue, when, offer, up;
  final int price;
  final Art art;
  final List<String> friends;
  final String? creator;
  const Event({
    required this.id,
    required this.title,
    required this.cat,
    required this.venue,
    required this.when,
    required this.price,
    required this.art,
    required this.friends,
    required this.offer,
    required this.up,
    this.creator,
  });
  @override
  List<Object?> get props => [id];
}

class Ticket extends Equatable {
  final String id, eventId;
  final int qty, total, seed;
  const Ticket({required this.id, required this.eventId, required this.qty, required this.total, required this.seed});
  @override
  List<Object?> get props => [id];
}

/// Pure price calculation shared by the UI and the booking use case.
class EventQuote extends Equatable {
  final int base, discount, total, points;
  const EventQuote(this.base, this.discount, this.total, this.points);

  factory EventQuote.of(Event e, {required int qty, required bool applyPass, required bool planIsPaid}) {
    final base = e.price * qty;
    final discount = (applyPass && planIsPaid) ? (base * .2).round() : 0;
    return EventQuote(base, discount, base - discount, qty * 125);
  }

  @override
  List<Object?> get props => [base, discount, total, points];
}
