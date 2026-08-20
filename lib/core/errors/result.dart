import 'failure.dart';

/// Sealed class Result untuk fungsional error handling
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.error(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    Error<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(failure: final f) => f,
  };

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(data: final d) => onSuccess(d),
      Error<T>(failure: final f) => onError(f),
    };
  }

  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(data: final d) => Result.success(transform(d)),
      Error<T>(failure: final f) => Result.error(f),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.data == data);

  @override
  int get hashCode => data.hashCode;
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);

  @override
  String toString() => 'Error(failure: $failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Error<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;
}
