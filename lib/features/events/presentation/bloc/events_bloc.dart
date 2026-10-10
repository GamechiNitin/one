import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/presentation/ui_notifier.dart';
import '../../../../core/usecase.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart' show LoadStatus;
import '../../domain/entities/event.dart';
import '../../domain/usecases/events_usecases.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();
  @override
  List<Object?> get props => [];
}

class EventsRequested extends EventsEvent {
  const EventsRequested();
}

class BookingSubmitted extends EventsEvent {
  final Event event;
  final int qty;
  final bool applyPass;
  const BookingSubmitted(this.event, this.qty, this.applyPass);
  @override
  List<Object?> get props => [event, qty, applyPass];
}

enum BookingStatus { idle, submitting, success, failure }

class EventsState extends Equatable {
  final LoadStatus status;
  final List<Event> events;
  final List<Ticket> tickets;
  final BookingStatus booking;
  final String? lastTicketId;

  const EventsState({
    this.status = LoadStatus.initial,
    this.events = const [],
    this.tickets = const [],
    this.booking = BookingStatus.idle,
    this.lastTicketId,
  });

  Event? event(String id) {
    for (final e in events) {
      if (e.id == id) return e;
    }
    return null;
  }

  Ticket? ticket(String id) {
    for (final t in tickets) {
      if (t.id == id) return t;
    }
    return null;
  }

  EventsState copyWith({LoadStatus? status, List<Event>? events, List<Ticket>? tickets, BookingStatus? booking, String? lastTicketId}) => EventsState(
        status: status ?? this.status,
        events: events ?? this.events,
        tickets: tickets ?? this.tickets,
        booking: booking ?? this.booking,
        lastTicketId: lastTicketId ?? this.lastTicketId,
      );

  @override
  List<Object?> get props => [status, events, tickets, booking, lastTicketId];
}

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEvents _getEvents;
  final GetTickets _getTickets;
  final BookEvent _book;
  final UiNotifier _ui;

  EventsBloc(this._getEvents, this._getTickets, this._book, this._ui) : super(const EventsState()) {
    on<EventsRequested>((e, emit) async {
      emit(state.copyWith(status: LoadStatus.loading, tickets: _getTickets()));
      final r = await _getEvents(const NoParams());
      r.fold((f) => emit(state.copyWith(status: LoadStatus.failure)), (list) => emit(state.copyWith(status: LoadStatus.success, events: list)));
    });
    on<BookingSubmitted>((e, emit) async {
      emit(state.copyWith(booking: BookingStatus.submitting));
      final r = await _book(BookEventParams(e.event, e.qty, e.applyPass));
      r.fold(
        (f) {
          if (f is InsufficientFundsFailure) _ui.show('msg.lowBalance');
          emit(state.copyWith(booking: BookingStatus.failure));
        },
        (t) => emit(state.copyWith(booking: BookingStatus.success, tickets: _getTickets(), lastTicketId: t.id)),
      );
    });
  }
}
