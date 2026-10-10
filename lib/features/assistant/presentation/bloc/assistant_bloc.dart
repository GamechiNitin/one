import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../domain/usecases/assistant_usecases.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();
  @override
  List<Object?> get props => [];
}

class AssistantStarted extends AssistantEvent {
  const AssistantStarted();
}

class AssistantMessageSent extends AssistantEvent {
  final String text;
  const AssistantMessageSent(this.text);
  @override
  List<Object?> get props => [text];
}

class AssistantActionTapped extends AssistantEvent {
  final AssistantAction action;
  const AssistantActionTapped(this.action);
  @override
  List<Object?> get props => [action];
}

class AssistantCleared extends AssistantEvent {
  const AssistantCleared();
}

class _FollowUp extends AssistantEvent {
  final ChatMessage message;
  const _FollowUp(this.message);
  @override
  List<Object?> get props => [message];
}

class AssistantState extends Equatable {
  final List<ChatMessage> messages;
  final bool typing;
  const AssistantState({this.messages = const [], this.typing = false});

  AssistantState copyWith({List<ChatMessage>? messages, bool? typing}) =>
      AssistantState(messages: messages ?? this.messages, typing: typing ?? this.typing);

  @override
  List<Object?> get props => [messages, typing];
}

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final SendAssistantMessage _send;
  final RunAssistantAction _run;
  final AssistantRepository _repo;

  AssistantBloc(this._send, this._run, this._repo) : super(const AssistantState()) {
    on<AssistantStarted>((e, emit) => emit(state.copyWith(messages: _repo.loadHistory())));
    on<AssistantMessageSent>(_onMessage);
    on<AssistantActionTapped>(_onAction);
    on<_FollowUp>((e, emit) => _append(emit, e.message));
    on<AssistantCleared>((e, emit) async {
      await _repo.clearHistory();
      emit(const AssistantState());
    });
  }

  void _append(Emitter<AssistantState> emit, ChatMessage m, {bool typing = false}) {
    final next = [...state.messages, m];
    emit(state.copyWith(messages: next, typing: typing));
    _repo.saveHistory(next);
  }

  Future<void> _onMessage(AssistantMessageSent e, Emitter<AssistantState> emit) async {
    _append(emit, ChatMessage(fromUser: true, text: e.text), typing: true);
    final r = await _send(e.text);
    r.fold(
      (f) => _append(emit, const ChatMessage(fromUser: false, textKey: 'assistant.offline')),
      (m) => _append(emit, m),
    );
  }

  Future<void> _onAction(AssistantActionTapped e, Emitter<AssistantState> emit) async {
    _append(emit, ChatMessage(fromUser: true, textKey: 'assistant.act.${e.action.key}'), typing: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final r = await _run(e.action.key);
    r.fold(
      (f) => emit(state.copyWith(typing: false)),
      (m) {
        _append(emit, m);
        if (e.action.key == 'restart') {
          Future<void>.delayed(const Duration(seconds: 5), () {
            if (!isClosed) add(const _FollowUp(ChatMessage(fromUser: false, textKey: 'assistant.backOnline')));
          });
        }
      },
    );
  }
}
