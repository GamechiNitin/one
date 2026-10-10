import 'result.dart';

abstract class UseCase<T, P> {
  const UseCase();
  Future<Result<T>> call(P params);
}

class NoParams {
  const NoParams();
}
