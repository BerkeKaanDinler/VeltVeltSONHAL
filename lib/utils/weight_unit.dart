import '../services/prefs_service.dart';

class WeightUnit {
  WeightUnit._();

  static const _kgToLbs = 2.20462;

  static String get suffix => PrefsService.unit;

  static bool get isLbs => PrefsService.unit != 'kg';

  static double display(double kg) =>
      isLbs ? double.parse((kg * _kgToLbs).toStringAsFixed(1)) : kg;

  static double toKg(double value) =>
      isLbs ? value / _kgToLbs : value;

  static String format(double kg) {
    final v = display(kg);
    final s = v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    return '$s $suffix';
  }

  static String formatVolume(double kgVolume) {
    final v = display(kgVolume);
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}k $suffix';
    }
    return '${v.toInt()} $suffix';
  }
}
