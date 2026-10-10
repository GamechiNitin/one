import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/presentation/ui_notifier.dart';
import '../../domain/entities/catalog.dart';
import '../../domain/usecases/catalog_usecases.dart';

class LibraryCubit extends Cubit<Library> {
  final LoadLibrary _load;
  final ToggleMyList _toggle;
  final UnlockItem _unlock;
  final MarkWatched _watched;
  final SaveOffer _saveOffer;
  final UiNotifier _ui;

  LibraryCubit(this._load, this._toggle, this._unlock, this._watched, this._saveOffer, this._ui) : super(const Library()) {
    emit(_load());
  }

  Future<void> toggleMyList(String id) async {
    final r = await _toggle(id);
    if (r.isOk) emit(r.value);
  }

  Future<void> unlock(Item item) async {
    final r = await _unlock(item);
    r.fold(
      (f) => _ui.show(f is InsufficientFundsFailure ? 'msg.lowBalance' : 'msg.error'),
      (lib) {
        emit(lib);
        _ui.show('msg.unlocked', [item.title]);
      },
    );
  }

  Future<void> saveOffer(String id) async {
    final r = await _saveOffer(id);
    if (r.isOk) {
      emit(r.value);
      _ui.show('msg.offerSaved');
    }
  }

  Future<void> markWatched(Item item) async {
    await _watched(item);
    emit(_load());
  }
}
