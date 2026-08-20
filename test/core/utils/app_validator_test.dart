import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/core/utils/app_validator.dart';

void main() {
  group('AppValidator', () {
    test('required returns error if string is null or empty', () {
      expect(AppValidator.required(null, 'Nama'), 'Nama tidak boleh kosong');
      expect(AppValidator.required('', 'Nama'), 'Nama tidak boleh kosong');
      expect(AppValidator.required('   ', 'Nama'), 'Nama tidak boleh kosong');
      expect(AppValidator.required('Toko Berkah', 'Nama'), isNull);
    });

    test('positiveNumber validates strictly positive values', () {
      expect(
        AppValidator.positiveNumber('0', 'Harga'),
        'Harga harus lebih besar dari 0',
      );
      expect(
        AppValidator.positiveNumber('-500', 'Harga'),
        'Harga harus lebih besar dari 0',
      );
      expect(AppValidator.positiveNumber('15000', 'Harga'), isNull);
    });

    test('nonNegativeNumber validates values >= 0', () {
      expect(
        AppValidator.nonNegativeNumber('-1', 'Stok'),
        'Stok tidak boleh negatif',
      );
      expect(AppValidator.nonNegativeNumber('0', 'Stok'), isNull);
      expect(AppValidator.nonNegativeNumber('10', 'Stok'), isNull);
    });
  });
}
