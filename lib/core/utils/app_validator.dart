/// Form validator helper dengan pesan ramah Bahasa Indonesia
class AppValidator {
  AppValidator._();

  static String? required(String? value, [String fieldName = 'Bidang ini']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Nilai']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9.-]'), '');
    final numValue = double.tryParse(clean);
    if (numValue == null || numValue <= 0) {
      return '$fieldName harus lebih besar dari 0';
    }
    return null;
  }

  static String? nonNegativeNumber(
    String? value, [
    String fieldName = 'Nilai',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9.-]'), '');
    final numValue = double.tryParse(clean);
    if (numValue == null || numValue < 0) {
      return '$fieldName tidak boleh negatif';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.length < 4) {
      return 'PIN minimal 4 digit angka';
    }
    return null;
  }
}
