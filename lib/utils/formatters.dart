import 'package:intl/intl.dart';

class PokeetFmt {
  static const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  static const double _crore = 1e7;

  static String toDigits(String input, bool isEn) {
    if (isEn) return input;
    final buf = StringBuffer();
    for (final ch in input.split('')) {
      final code = ch.codeUnitAt(0);
      if (code >= 48 && code <= 57) {
        buf.write(_bnDigits[code - 48]);
      } else {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  static String money(double value, {bool isEn = false, bool hide = false, bool showSign = false}) {
    if (hide) return '****';
    final sign = value < 0 ? '-' : (showSign && value > 0 ? '+' : '');
    final absVal = value.abs();
    if (absVal > _crore) {
      final cr = (absVal / _crore).toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
      final unit = isEn ? ' Cr' : ' কোটি';
      return '$sign৳${toDigits(cr, isEn)}$unit';
    }
    final fmt = NumberFormat('#,##0.##', 'en_US').format(absVal);
    return '$sign৳${toDigits(fmt, isEn)}';
  }
}
