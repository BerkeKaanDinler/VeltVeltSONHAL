// VELT — Pro service (RevenueCat)
//
// Wraps RevenueCat for subscription management. If REVENUECAT_*_KEY env
// vars are not provided, the service is a no-op and `isPro` stays false
// (everything reads as Free tier). UI gates Pro features off `isPro`.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import '../config/env.dart';

class ProOffering {
  const ProOffering({
    required this.identifier,
    required this.title,
    required this.priceString,
    required this.period,
    required this.rawPackage,
  });
  final String identifier;
  final String title;
  final String priceString;
  final String period; // 'monthly' | 'annual' | 'lifetime'
  final rc.Package rawPackage;
}

class ProService {
  ProService._();

  static bool _ready = false;
  static bool get isConfigured => Env.revenueCatEnabled;

  /// True if user has an active Pro entitlement.
  static final ValueNotifier<bool> isPro = ValueNotifier<bool>(false);
  static final ValueNotifier<List<ProOffering>> offerings =
      ValueNotifier<List<ProOffering>>([]);

  static const _entitlementId = 'pro';

  static Future<void> init() async {
    if (!isConfigured) {
      debugPrint('[ProService] RevenueCat not configured — Pro disabled.');
      return;
    }
    try {
      late rc.PurchasesConfiguration cfg;
      if (Platform.isIOS || Platform.isMacOS) {
        cfg = rc.PurchasesConfiguration(Env.revenueCatAppleKey);
      } else if (Platform.isAndroid) {
        cfg = rc.PurchasesConfiguration(Env.revenueCatGoogleKey);
      } else {
        return; // Web / desktop unsupported here
      }
      await rc.Purchases.configure(cfg);
      _ready = true;
      await refresh();
      rc.Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
    } catch (e, st) {
      debugPrint('[ProService] init failed: $e\n$st');
    }
  }

  static void _onCustomerInfo(rc.CustomerInfo info) {
    final active = info.entitlements.active.containsKey(_entitlementId);
    if (isPro.value != active) {
      isPro.value = active;
    }
  }

  /// Reload entitlement + offerings from RC.
  static Future<void> refresh() async {
    if (!_ready) return;
    try {
      final info = await rc.Purchases.getCustomerInfo();
      _onCustomerInfo(info);
      final raw = await rc.Purchases.getOfferings();
      final current = raw.current;
      if (current == null) {
        offerings.value = [];
        return;
      }
      final list = <ProOffering>[];
      for (final pkg in current.availablePackages) {
        list.add(ProOffering(
          identifier: pkg.identifier,
          title: pkg.storeProduct.title,
          priceString: pkg.storeProduct.priceString,
          period: _periodOf(pkg.packageType),
          rawPackage: pkg,
        ));
      }
      offerings.value = list;
    } catch (e) {
      debugPrint('[ProService] refresh failed: $e');
    }
  }

  static String _periodOf(rc.PackageType t) {
    switch (t) {
      case rc.PackageType.monthly:
        return 'monthly';
      case rc.PackageType.annual:
        return 'annual';
      case rc.PackageType.lifetime:
        return 'lifetime';
      case rc.PackageType.weekly:
        return 'weekly';
      default:
        return 'other';
    }
  }

  /// Attempt to purchase the given offering. Returns null on success,
  /// or an error message on failure (cancelled, billing error, etc.).
  static Future<String?> purchase(ProOffering offering) async {
    if (!_ready) return 'Subscriptions not configured.';
    try {
      final info = await rc.Purchases.purchasePackage(offering.rawPackage);
      _onCustomerInfo(info);
      return null;
    } on rc.PurchasesErrorCode catch (e) {
      return e.toString();
    } catch (e) {
      return e.toString();
    }
  }

  /// Restore previously purchased entitlements (Apple requirement).
  static Future<String?> restore() async {
    if (!_ready) return 'Subscriptions not configured.';
    try {
      final info = await rc.Purchases.restorePurchases();
      _onCustomerInfo(info);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Link the RC user to the signed-in Supabase user id, so subscriptions
  /// follow the account across devices.
  static Future<void> identify(String userId) async {
    if (!_ready) return;
    try {
      await rc.Purchases.logIn(userId);
      await refresh();
    } catch (e) {
      debugPrint('[ProService] identify failed: $e');
    }
  }

  static Future<void> logout() async {
    if (!_ready) return;
    try {
      await rc.Purchases.logOut();
      await refresh();
    } catch (e) {
      debugPrint('[ProService] logout failed: $e');
    }
  }
}
