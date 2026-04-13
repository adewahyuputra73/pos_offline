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
