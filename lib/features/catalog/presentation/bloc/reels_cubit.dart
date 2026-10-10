import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../wallet/domain/usecases/wallet_usecases.dart';

/// Tracks the visible reel and awards 5 points for every third reel watched for 3 seconds.
class ReelsCubit extends Cubit<int> {
  final AwardPoints _award;
  Timer? _timer;
  final Set<int> _seen = {};

  ReelsCubit(this._award) : super(0);

  void open(int index) {
    emit(index);
    _arm(index);
  }

  void onPageChanged(int index) {
    emit(index);
    _arm(index);
  }

  void _arm(int index) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (_seen.add(index) && _seen.length % 3 == 0) {
        _award(const AwardPointsParams(5, 'Watched reels'));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
