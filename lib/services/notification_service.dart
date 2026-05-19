import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract final class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _kRestTimerId = 1;

  static const _kAndroidChannelId   = 'velt_rest_timer';
  static const _kAndroidChannelName = 'Rest Timer';

  static bool _initialized = false;

  // ── Init — call once in main() after timezone is configured ──
  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );
    _initialized = true;
  }

  // ── Request OS-level permission (iOS alert + sound; Android 13+ POST) ──
  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true, badge: false);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Schedule rest timer notification at exact wall-clock time ──
  // Safe to call multiple times — cancels any existing rest timer first.
  static Future<void> scheduleRestTimer(DateTime expiresAt) async {
    // Don't schedule if already in the past (< 2s headroom)
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining < 2) return;

    await _plugin.cancel(_kRestTimerId);

    await _plugin.zonedSchedule(
      _kRestTimerId,
      'Rest complete',
      'Time for your next set — get after it.',
      tz.TZDateTime.from(expiresAt, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        android: AndroidNotificationDetails(
          _kAndroidChannelId,
          _kAndroidChannelName,
          channelDescription: 'Fires when your rest period ends',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Cancel the pending rest timer notification ──
  static Future<void> cancelRestTimer() async {
    await _plugin.cancel(_kRestTimerId);
  }
}
