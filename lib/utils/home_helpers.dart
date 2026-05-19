import '../models/routine.dart';

abstract final class HomeHelpers {
  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 5)  return 'Still up?';
    if (h < 12) return 'Good morning.';
    if (h < 17) return 'Good afternoon.';
    if (h < 21) return 'Good evening.';
    return 'Late session?';
  }

  static String motivationLine(int streak, bool doneToday, int prCount) {
    if (doneToday && prCount > 0) return 'New PR today. Keep building.';
    if (doneToday) return 'Session complete. Rest and recover.';
    if (prCount > 10 && streak >= 7) return 'Elite level — $streak days, $prCount PRs.';
    if (prCount > 0 && streak == 0) return '$prCount personal records set. Start a streak.';
    if (streak == 0) return 'Every legend starts somewhere.';
    if (streak < 4)  return 'Building the habit. Keep going.';
    if (streak < 8)  return "The streak is real — don't break it.";
    if (streak < 15) return '$streak days and counting. Impressive.';
    return "You're in the top 1%. $streak day streak.";
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static Routine pickNextRoutine(List<Routine> routines) {
    return routines.reduce((a, b) {
      if (a.lastDone == null) return a;
      if (b.lastDone == null) return b;
      return a.lastDone!.isBefore(b.lastDone!) ? a : b;
    });
  }
}
