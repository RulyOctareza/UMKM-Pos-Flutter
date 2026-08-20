import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Formatter tanggal dan waktu lokal Indonesia
class DateFormatter {
  DateFormatter._();

  static bool _isInitialized = false;

  static void _ensureInitialized() {
    if (!_isInitialized) {
      initializeDateFormatting('id_ID', null);
      _isInitialized = true;
    }
  }

  static DateFormat get _dateFormat {
    _ensureInitialized();
    try {
      return DateFormat('dd MMM yyyy', 'id_ID');
    } catch (_) {
      return DateFormat('dd MMM yyyy');
    }
  }

  static DateFormat get _dateTimeFormat {
    _ensureInitialized();
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm');
    }
  }

  static DateFormat get _timeFormat {
    _ensureInitialized();
    try {
      return DateFormat('HH:mm', 'id_ID');
    } catch (_) {
      return DateFormat('HH:mm');
    }
  }

  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatIso(DateTime date) => _isoFormat.format(date);

  /// Label relatif ramah kasir: "Hari Ini, 14:30", "Kemarin, 09:15", "18 Agu 2026, 12:00"
  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Hari ini, ${formatTime(date)}';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin, ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }
}
