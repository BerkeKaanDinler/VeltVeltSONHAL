import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get tabTrain;

  /// No description provided for @tabNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get tabNutrition;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get actionStartWorkout;

  /// No description provided for @actionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get actionFinish;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @homeTodayPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get homeTodayPlan;

  /// No description provided for @homeStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get homeStartWorkout;

  /// No description provided for @homeQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get homeQuickAccess;

  /// No description provided for @homeRepeatSession.
  ///
  /// In en, this message translates to:
  /// **'Repeat a session'**
  String get homeRepeatSession;

  /// No description provided for @homeLastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Last workout'**
  String get homeLastWorkout;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get homeEmpty;

  /// No description provided for @trainExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get trainExercises;

  /// No description provided for @trainPrograms.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get trainPrograms;

  /// No description provided for @trainRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get trainRoutines;

  /// No description provided for @trainAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get trainAddSet;

  /// No description provided for @trainAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get trainAddExercise;

  /// No description provided for @trainWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warmup'**
  String get trainWarmup;

  /// No description provided for @trainRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get trainRest;

  /// No description provided for @profileSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync'**
  String get profileSignInTitle;

  /// No description provided for @profileSignInSub.
  ///
  /// In en, this message translates to:
  /// **'Backup workouts, switch devices, never lose data'**
  String get profileSignInSub;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profilePro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get profilePro;

  /// No description provided for @profileFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get profileFree;

  /// No description provided for @paywallStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-day free trial'**
  String get paywallStartTrial;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallContinueFree.
  ///
  /// In en, this message translates to:
  /// **'Continue with Free'**
  String get paywallContinueFree;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline.'**
  String get errorOffline;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get weightKg;

  /// No description provided for @weightLb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get weightLb;

  /// No description provided for @unitsKilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get unitsKilograms;

  /// No description provided for @unitsPounds.
  ///
  /// In en, this message translates to:
  /// **'Pounds'**
  String get unitsPounds;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'tr':
      return AppL10nTr();
  }

  throw FlutterError(
      'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
