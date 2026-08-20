/// Sealed hierarchy Failure untuk Clean Architecture error handling
sealed class Failure {
  final String message;
  final String? code;
  final dynamic cause;

  const Failure(this.message, {this.code, this.cause});

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code, super.cause});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.cause});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.cause});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.cause});
}

class SyncFailure extends Failure {
  const SyncFailure(super.message, {super.code, super.cause});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Terjadi kesalahan yang tidak terduga',
    dynamic cause,
  ]) : super(cause: cause);
}
