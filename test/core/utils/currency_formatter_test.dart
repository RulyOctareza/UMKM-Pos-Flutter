import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pos/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('format formats numbers to Indonesian Rupiah correctly', () {
      expect(CurrencyFormatter.format(0), 'Rp 0');
      expect(CurrencyFormatter.format(15000), 'Rp 15.000');
      expect(CurrencyFormatter.format(1250000), 'Rp 1.250.000');
    });

    test('formatWithoutSymbol formats amount with thousand separators', () {
      expect(CurrencyFormatter.formatWithoutSymbol(15000), '15.000');
      expect(CurrencyFormatter.formatWithoutSymbol(500000), '500.000');
    });

    test('parse parses currency text back to numeric double value', () {
      expect(CurrencyFormatter.parse('Rp 15.000'), 15000.0);
      expect(CurrencyFormatter.parse('1.250.000'), 1250000.0);
      expect(CurrencyFormatter.parse('invalid'), 0.0);
    });
  });
}
