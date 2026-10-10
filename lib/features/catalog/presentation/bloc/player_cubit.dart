import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/catalog.dart';
import '../../domain/usecases/catalog_usecases.dart';

class PlayerState extends Equatable {
  final double progress;
  final double seconds;
  final bool paused;
  final List<String> chat;
  const PlayerState({this.progress = 0, this.seconds = 0, this.paused = false, this.chat = const []});

  PlayerState copyWith({double? progress, double? seconds, bool? paused, List<String>? chat}) => PlayerState(
        progress: progress ?? this.progress,
        seconds: seconds ?? this.seconds,
        paused: paused ?? this.paused,
        chat: chat ?? this.chat,
      );

  @override
  List<Object?> get props => [progress, seconds, paused, chat];
}

/// Simulated playback: progress, live chat, and the "watched" reward after 6 seconds.
class PlayerCubit extends Cubit<PlayerState> {
  final MarkWatched _markWatched;
  final _rnd = math.Random();
  Timer? _tick, _chat;
  bool _rewarded = false;

  static const _names = ['Riya', 'Aarav', 'Megha', 'Karan', 'Yash', 'Divya'];
  static const _lines = ['That bassline!', 'Here for this', 'Turn it up', 'Who else is in Chennai?', 'Absolute scenes', 'Replay that', 'Goosebumps', 'Booking the next one'];

  PlayerCubit(this._markWatched) : super(const PlayerState());

  void start(Item item) {
    emit(PlayerState(progress: item.progress));
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (state.paused || isClosed) return;
      final s = state.seconds + .25;
      emit(state.copyWith(seconds: s, progress: math.min(1, state.progress + .0025)));
      if (s >= 6 && !_rewarded) {
        _rewarded = true;
        _markWatched(item);
      }
    });
    if (item.live) {
      _chat = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        if (state.paused || isClosed) return;
        final next = [...state.chat, '${_names[_rnd.nextInt(_names.length)]}|${_lines[_rnd.nextInt(_lines.length)]}'];
        emit(state.copyWith(chat: next.length > 6 ? next.sublist(next.length - 6) : next));
      });
    }
  }

  void togglePause() => emit(state.copyWith(paused: !state.paused));

  @override
  Future<void> close() {
    _tick?.cancel();
    _chat?.cancel();
    return super.close();
  }
}
