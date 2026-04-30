import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _idr = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final DateFormat _dateFull = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
final DateFormat _dateShort = DateFormat('dd MMM yyyy', 'id_ID');
final DateFormat _timeOnly = DateFormat('HH:mm', 'id_ID');

String formatRupiah(num value) => _idr.format(value);

String formatDateFull(DateTime dt) => _dateFull.format(dt);
String formatDateShort(DateTime dt) => _dateShort.format(dt);
String formatTime(DateTime dt) => _timeOnly.format(dt);

/// Parse a formatted number string (e.g. "25.000") back to int.
int parseFormattedNumber(String text) {
  return int.tryParse(text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
}

/// TextInputFormatter that adds thousand separators (dots) as the user types.
/// e.g. 25000 → 25.000
class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // Format with dots
    final number = int.parse(digitsOnly);
    final formatted = NumberFormat('#,###', 'id_ID').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
