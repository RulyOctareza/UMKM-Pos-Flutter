import 'package:intl/intl.dart';

/// Formatter mata uang Rupiah Indonesia (IDR)
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactCurrencyFormat =
      NumberFormat.compactCurrency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 1,
      );

  /// Format angka ke bentuk "Rp 15.000"
  static String format(num amount) {
    return _currencyFormat.format(amount);
  }

  /// Format angka tanpa prefix simbol "15.000"
  static String formatWithoutSymbol(num amount) {
    final format = NumberFormat('#,###', 'id_ID');
    return format.format(amount);
  }

  /// Format angka ringkas untuk grafik/dashboard mis. "Rp 1,5 jt"
  static String formatCompact(num amount) {
    return _compactCurrencyFormat.format(amount);
  }

  /// Parse string angka Rupiah ke num/double
  static double parse(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}
