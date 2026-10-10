import 'error/failure.dart';

/// Minimal Either-style result used by repositories and use cases.
class Result<T> {
  final T? _value;
  final Failure? failure;
  const Result._(this._value, this.failure);
  const Result.ok(T value) : this._(value, null);
  const Result.err(Failure failure) : this._(null, failure);

  bool get isOk => failure == null;
  T get value => _value as T;

  R fold<R>(R Function(Failure f) onFailure, R Function(T v) onSuccess) =>
      failure != null ? onFailure(failure!) : onSuccess(_value as T);
}

class Unit {
  const Unit();
}

const unit = Unit();
