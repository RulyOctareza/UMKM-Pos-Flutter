import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/core/errors/failure.dart';
import 'package:umkm_pos/core/errors/result.dart';

void main() {
  group('Result<T>', () {
    test('Success holds data and isSuccess is true', () {
      const result = Result.success('hello');
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.dataOrNull, 'hello');
      expect(result.failureOrNull, isNull);
    });

    test('Error holds failure and isError is true', () {
      const failure = ValidationFailure('invalid input');
      const result = Result<String>.error(failure);
      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('when callback handles success and error cases', () {
      const successResult = Result.success(100);
      final successValue = successResult.when(
        onSuccess: (data) => data * 2,
        onError: (_) => 0,
      );
      expect(successValue, 200);

      const errorResult = Result<int>.error(DatabaseFailure('DB error'));
      final errorValue = errorResult.when(
        onSuccess: (data) => data,
        onError: (f) => -1,
      );
      expect(errorValue, -1);
    });
  });
}
