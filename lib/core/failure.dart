abstract class Failure {
  final String message;
  final int? code; 
  const Failure(this.message, {this.code});
}

// tipos específicos de fallos
class ApiFailure extends Failure {
  const ApiFailure(super.message, {super.code});
}
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}