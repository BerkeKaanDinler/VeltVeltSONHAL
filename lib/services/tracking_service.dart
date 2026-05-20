// VELT — App Tracking Transparency (iOS) wrapper.
//
// Apple requires apps that perform ANY cross-app tracking (analytics SDKs,
// ad attribution) to display the ATT prompt before tracking starts. Failing
// to prompt is grounds for App Store rejection.
//
// We call `request()` once after onboarding completes — the OS guarantees
// the dialog only appears the first time per install.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class TrackingService {
  TrackingService._();

  /// Show the ATT prompt if needed. Safe to call on any platform; on
  /// Android / web this is a no-op.
  static Future<void> requestIfNeeded() async {
    if (!Platform.isIOS) return;
    try {
      final status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // Slight delay so the dialog doesn't collide with onboarding's last
        // frame transition.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('[TrackingService] request failed: $e');
    }
  }
}
