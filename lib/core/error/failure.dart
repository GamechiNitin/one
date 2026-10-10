import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No connection');
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class InsufficientFundsFailure extends Failure {
  final int shortBy;
  const InsufficientFundsFailure(this.shortBy) : super('Insufficient funds');
  @override
  List<Object?> get props => [message, shortBy];
}

class InsufficientPointsFailure extends Failure {
  final int shortBy;
  const InsufficientPointsFailure(this.shortBy) : super('Insufficient points');
  @override
  List<Object?> get props => [message, shortBy];
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid request']);
}
