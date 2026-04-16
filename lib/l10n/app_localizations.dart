import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('nl')
  ];

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s improve your'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PostureCare helps users assess their posture, get ISO-aligned corrections, follow personalized exercises, and track improvements for healthier work habits'**
  String get splashSubtitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Improve Posture. Reduce Pain'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Start Your ISO-Aligned Assessment'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Science-Backed Posture Insights'**
  String get onboardingTitle3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Posture care'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PostureCare helps users assess their posture, get ISO-aligned corrections, follow personalized exercises!'**
  String get welcomeSubtitle;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createNewAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @chooseModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Mode'**
  String get chooseModeTitle;

  /// No description provided for @chooseModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ISO-aligned ergonomic assessment and recommendations'**
  String get chooseModeSubtitle;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @businessTitle.
  ///
  /// In en, this message translates to:
  /// **'Companies, HR, Admin, Desk Workers'**
  String get businessTitle;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @privateTitle.
  ///
  /// In en, this message translates to:
  /// **'Home / Remote works'**
  String get privateTitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectLanguageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get dutch;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @companyLogin.
  ///
  /// In en, this message translates to:
  /// **'Company Login'**
  String get companyLogin;

  /// No description provided for @companyLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your company code to continue'**
  String get companyLoginSubtitle;

  /// No description provided for @enterYourCompanyCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your company code'**
  String get enterYourCompanyCode;

  /// No description provided for @enterYourCompanyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. COMPANY-123'**
  String get enterYourCompanyCodeHint;

  /// No description provided for @iDonHaveCode.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have a code →'**
  String get iDonHaveCode;

  /// No description provided for @contactAdministration.
  ///
  /// In en, this message translates to:
  /// **'Contact Administrator'**
  String get contactAdministration;

  /// No description provided for @userIdentification.
  ///
  /// In en, this message translates to:
  /// **'User Identification'**
  String get userIdentification;

  /// No description provided for @userIdentificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link your assessment to your desk and department'**
  String get userIdentificationSubtitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameHint;

  /// No description provided for @employId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employId;

  /// No description provided for @employIdHint.
  ///
  /// In en, this message translates to:
  /// **'Your employee ID'**
  String get employIdHint;

  /// No description provided for @workstationSetup.
  ///
  /// In en, this message translates to:
  /// **'Workstation Setup'**
  String get workstationSetup;

  /// No description provided for @workstationSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link your assessment to your workstation and department'**
  String get workstationSetupSubtitle;

  /// No description provided for @workstationType.
  ///
  /// In en, this message translates to:
  /// **'Workstation type'**
  String get workstationType;

  /// No description provided for @deskId.
  ///
  /// In en, this message translates to:
  /// **'Desk ID or Location (Recommended)'**
  String get deskId;

  /// No description provided for @deskIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Floor 3, Desk 42'**
  String get deskIdHint;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @departmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Marketing'**
  String get departmentHint;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @roleHint.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get roleHint;

  /// No description provided for @desk.
  ///
  /// In en, this message translates to:
  /// **'Desk'**
  String get desk;

  /// No description provided for @standingDesk.
  ///
  /// In en, this message translates to:
  /// **'Standing desk'**
  String get standingDesk;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @bodyRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select body region(s) with discomfort'**
  String get bodyRegionTitle;

  /// No description provided for @bodyRegionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select where do you feel discomfort'**
  String get bodyRegionSubtitle;

  /// No description provided for @neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get neck;

  /// No description provided for @elbow.
  ///
  /// In en, this message translates to:
  /// **'Elbows/Forearms'**
  String get elbow;

  /// No description provided for @upperBack.
  ///
  /// In en, this message translates to:
  /// **'Upper Back'**
  String get upperBack;

  /// No description provided for @shoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulder;

  /// No description provided for @wrist.
  ///
  /// In en, this message translates to:
  /// **'Wrists/Hands'**
  String get wrist;

  /// No description provided for @lowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower Back'**
  String get lowerBack;

  /// No description provided for @painIntensity.
  ///
  /// In en, this message translates to:
  /// **'Pain intensity'**
  String get painIntensity;

  /// No description provided for @painIntensitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Score your pain intensity'**
  String get painIntensitySubtitle;

  /// No description provided for @painDuration.
  ///
  /// In en, this message translates to:
  /// **'Pain duration / pattern'**
  String get painDuration;

  /// No description provided for @painDurationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your pain duration pattern'**
  String get painDurationSubtitle;

  /// No description provided for @lessThanWeek.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 week'**
  String get lessThanWeek;

  /// No description provided for @week1To6.
  ///
  /// In en, this message translates to:
  /// **'1-6 weeks'**
  String get week1To6;

  /// No description provided for @moreThan6Week.
  ///
  /// In en, this message translates to:
  /// **'More than 6 weeks'**
  String get moreThan6Week;

  /// No description provided for @onOffForMonth.
  ///
  /// In en, this message translates to:
  /// **'On/off for months'**
  String get onOffForMonth;

  /// No description provided for @workPattern.
  ///
  /// In en, this message translates to:
  /// **'Work Pattern'**
  String get workPattern;

  /// No description provided for @workPatternSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your work pattern'**
  String get workPatternSubtitle;

  /// No description provided for @hoursAtDeskPerDay.
  ///
  /// In en, this message translates to:
  /// **'Hours at desk per day'**
  String get hoursAtDeskPerDay;

  /// No description provided for @hoursPerDayHint.
  ///
  /// In en, this message translates to:
  /// **'0-4 Hours'**
  String get hoursPerDayHint;

  /// No description provided for @breakHabits.
  ///
  /// In en, this message translates to:
  /// **'Break habits'**
  String get breakHabits;

  /// No description provided for @breakHabitsHint.
  ///
  /// In en, this message translates to:
  /// **'Every 3 Hours'**
  String get breakHabitsHint;

  /// No description provided for @deviceSetup.
  ///
  /// In en, this message translates to:
  /// **'Device setup'**
  String get deviceSetup;

  /// No description provided for @selectDeviceUsage.
  ///
  /// In en, this message translates to:
  /// **'Select device setup'**
  String get selectDeviceUsage;

  /// No description provided for @laptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get laptop;

  /// No description provided for @singleScreen.
  ///
  /// In en, this message translates to:
  /// **'Single Screen'**
  String get singleScreen;

  /// No description provided for @dualScreen.
  ///
  /// In en, this message translates to:
  /// **'Dual Screen'**
  String get dualScreen;

  /// No description provided for @mouseType.
  ///
  /// In en, this message translates to:
  /// **'Mouse type'**
  String get mouseType;

  /// No description provided for @standardMouse.
  ///
  /// In en, this message translates to:
  /// **'Standard mouse'**
  String get standardMouse;

  /// No description provided for @smallOrNotebookMouse.
  ///
  /// In en, this message translates to:
  /// **'Small or notebook mouse'**
  String get smallOrNotebookMouse;

  /// No description provided for @trackpadOrNoMouse.
  ///
  /// In en, this message translates to:
  /// **'Trackpad or no mouse'**
  String get trackpadOrNoMouse;

  /// No description provided for @optionalSymptom.
  ///
  /// In en, this message translates to:
  /// **'Optional Symptoms'**
  String get optionalSymptom;

  /// No description provided for @optionalSymptomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select optional symptoms'**
  String get optionalSymptomSubtitle;

  /// No description provided for @tingling.
  ///
  /// In en, this message translates to:
  /// **'Tingling'**
  String get tingling;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// No description provided for @endOfDayPain.
  ///
  /// In en, this message translates to:
  /// **'End-of-day pain'**
  String get endOfDayPain;

  /// No description provided for @stiffness.
  ///
  /// In en, this message translates to:
  /// **'Stiffness'**
  String get stiffness;

  /// No description provided for @morningPain.
  ///
  /// In en, this message translates to:
  /// **'Morning pain'**
  String get morningPain;

  /// No description provided for @photoCaptureGuide.
  ///
  /// In en, this message translates to:
  /// **'Photo Capture Guide'**
  String get photoCaptureGuide;

  /// No description provided for @personA.
  ///
  /// In en, this message translates to:
  /// **'Person A (You)'**
  String get personA;

  /// No description provided for @guideA1.
  ///
  /// In en, this message translates to:
  /// **'Sit exactly as you normally work'**
  String get guideA1;

  /// No description provided for @guideA2.
  ///
  /// In en, this message translates to:
  /// **'Place hands on keyboard/mouse'**
  String get guideA2;

  /// No description provided for @guideA3.
  ///
  /// In en, this message translates to:
  /// **'Look at screen naturally'**
  String get guideA3;

  /// No description provided for @guideA4.
  ///
  /// In en, this message translates to:
  /// **'Maintain your natural posture'**
  String get guideA4;

  /// No description provided for @personB.
  ///
  /// In en, this message translates to:
  /// **'Person B (Photo Taker)'**
  String get personB;

  /// No description provided for @guideB1.
  ///
  /// In en, this message translates to:
  /// **'Hold phone at worker\'s eye level'**
  String get guideB1;

  /// No description provided for @guideB2.
  ///
  /// In en, this message translates to:
  /// **'Stand at worker\'s side (90° angle)'**
  String get guideB2;

  /// No description provided for @guideB3.
  ///
  /// In en, this message translates to:
  /// **'Ensure full body visible in frame'**
  String get guideB3;

  /// No description provided for @guideB4.
  ///
  /// In en, this message translates to:
  /// **'Wait for green validation indicator'**
  String get guideB4;

  /// No description provided for @primaryScan.
  ///
  /// In en, this message translates to:
  /// **'Primary Scan'**
  String get primaryScan;

  /// No description provided for @primaryScanInfo.
  ///
  /// In en, this message translates to:
  /// **'If you perform a primary scan, you will get a new set of suggestions and score and your previous scores and suggestions will be replaced by the new OR You can perform an Instant scan!'**
  String get primaryScanInfo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yesSure.
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m Sure'**
  String get yesSure;

  /// No description provided for @instantScan.
  ///
  /// In en, this message translates to:
  /// **'Instant Scan'**
  String get instantScan;

  /// No description provided for @instantScanInfo.
  ///
  /// In en, this message translates to:
  /// **'If you perform an instant scan, you will get a new set of suggestions and score and your previous scores and suggestions will be replaced by the new.'**
  String get instantScanInfo;

  /// No description provided for @consentToUpload.
  ///
  /// In en, this message translates to:
  /// **'Do you consent to upload this photo?'**
  String get consentToUpload;

  /// No description provided for @consentToUploadInfo.
  ///
  /// In en, this message translates to:
  /// **'To analyze your posture, this photo must be uploaded to our secure servers. It will be stored encrypted for up to 12 months and deleted earlier if you request it.'**
  String get consentToUploadInfo;

  /// No description provided for @photoPreview.
  ///
  /// In en, this message translates to:
  /// **'Photo Preview'**
  String get photoPreview;

  /// No description provided for @analyzingPosture.
  ///
  /// In en, this message translates to:
  /// **'Analyzing posture...'**
  String get analyzingPosture;

  /// No description provided for @iso9241.
  ///
  /// In en, this message translates to:
  /// **'ISO 9241.5:2024 compliance check'**
  String get iso9241;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @rosaErgonomicAnalysis.
  ///
  /// In en, this message translates to:
  /// **'ROSA Ergonomic Analysis'**
  String get rosaErgonomicAnalysis;

  /// No description provided for @basedOnIso9241.
  ///
  /// In en, this message translates to:
  /// **'Based on ISO 9241.5:2024'**
  String get basedOnIso9241;

  /// No description provided for @compliance.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get compliance;

  /// No description provided for @yourOverallScore.
  ///
  /// In en, this message translates to:
  /// **'Your overall score:'**
  String get yourOverallScore;

  /// No description provided for @immediateCorrection.
  ///
  /// In en, this message translates to:
  /// **'Immediate correction required'**
  String get immediateCorrection;

  /// No description provided for @detailsAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Details Analysis'**
  String get detailsAnalysis;

  /// No description provided for @detailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get detailedAnalysis;

  /// No description provided for @riskByBodyRegion.
  ///
  /// In en, this message translates to:
  /// **'Risk by Body Region'**
  String get riskByBodyRegion;

  /// No description provided for @viewCorrection.
  ///
  /// In en, this message translates to:
  /// **'View corrections'**
  String get viewCorrection;

  /// No description provided for @miniIsoCorrection.
  ///
  /// In en, this message translates to:
  /// **'Mini ISO Correction Report'**
  String get miniIsoCorrection;

  /// No description provided for @miniIsoCorrectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The following adjustments are recommended based on your posture analysis:'**
  String get miniIsoCorrectionSubtitle;

  /// No description provided for @viewExercise.
  ///
  /// In en, this message translates to:
  /// **'View Exercise'**
  String get viewExercise;

  /// No description provided for @personalizedExerciseProgram.
  ///
  /// In en, this message translates to:
  /// **'Personalized Exercise Program'**
  String get personalizedExerciseProgram;

  /// No description provided for @personalizedExerciseProgramSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The following exercise are recommended based on your posture analysis:'**
  String get personalizedExerciseProgramSubtitle;

  /// No description provided for @postureAdjustmentRecommendation.
  ///
  /// In en, this message translates to:
  /// **'The following adjustments are recommended based on your posture analysis:'**
  String get postureAdjustmentRecommendation;

  /// No description provided for @equipmentRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Equipment Recommendations'**
  String get equipmentRecommendations;

  /// No description provided for @equipmentRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your posture analysis, the following equipment is recommended to improve your ergonomic setup'**
  String get equipmentRecommendationsSubtitle;

  /// No description provided for @downloadList.
  ///
  /// In en, this message translates to:
  /// **'Download List'**
  String get downloadList;

  /// No description provided for @sendDataToCompany.
  ///
  /// In en, this message translates to:
  /// **'Send data to Company'**
  String get sendDataToCompany;

  /// No description provided for @openDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Dashboard'**
  String get openDashboard;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @welcomeToPostura.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Postura'**
  String get welcomeToPostura;

  /// No description provided for @immediateCorrectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Immediate correction required!'**
  String get immediateCorrectionRequired;

  /// No description provided for @scanYourPosture.
  ///
  /// In en, this message translates to:
  /// **'Scan your posture!'**
  String get scanYourPosture;

  /// No description provided for @scanYourPostureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan and get personalized posture'**
  String get scanYourPostureSubtitle;

  /// No description provided for @scanAndGetPersonalizedPosture.
  ///
  /// In en, this message translates to:
  /// **'Scan and get personalized posture'**
  String get scanAndGetPersonalizedPosture;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @elearning.
  ///
  /// In en, this message translates to:
  /// **'E-Learning'**
  String get elearning;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Policy'**
  String get privacyPolicy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @areYouSureTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to exit?'**
  String get areYouSureTitle;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @itWillProvideYouNewSet.
  ///
  /// In en, this message translates to:
  /// **'It will provide you new set of results and suggestions overall the app'**
  String get itWillProvideYouNewSet;

  /// No description provided for @newResultsSuggestionInfo.
  ///
  /// In en, this message translates to:
  /// **'It will provide you new set of results and suggestions overall the app'**
  String get newResultsSuggestionInfo;

  /// No description provided for @onlyShowInstantResult.
  ///
  /// In en, this message translates to:
  /// **'Only show you instant result'**
  String get onlyShowInstantResult;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @govtId.
  ///
  /// In en, this message translates to:
  /// **'Make sure this match the name on your any gov. ID.'**
  String get govtId;

  /// No description provided for @welcomeBackWithName.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBackWithName;

  /// No description provided for @individualUser.
  ///
  /// In en, this message translates to:
  /// **'Individual User'**
  String get individualUser;

  /// No description provided for @companyUser.
  ///
  /// In en, this message translates to:
  /// **'Company User'**
  String get companyUser;

  /// No description provided for @donHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get donHaveAnAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @forgetCredential.
  ///
  /// In en, this message translates to:
  /// **'Forget Credential'**
  String get forgetCredential;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmail;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm Email'**
  String get confirmEmail;

  /// No description provided for @weSend6digitCode.
  ///
  /// In en, this message translates to:
  /// **'We send a 4 digit verification code to your email.'**
  String get weSend6digitCode;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOTP;

  /// No description provided for @donGetCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code?'**
  String get donGetCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @confirmCode.
  ///
  /// In en, this message translates to:
  /// **'Confirm Code'**
  String get confirmCode;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @createNewAccountWith.
  ///
  /// In en, this message translates to:
  /// **'Create a new account with your email'**
  String get createNewAccountWith;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @byCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to the '**
  String get byCreatingAccount;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @congrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congrats;

  /// No description provided for @yourAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Your account is successfully created!'**
  String get yourAccountCreated;

  /// No description provided for @startCapturing.
  ///
  /// In en, this message translates to:
  /// **'Start Capturing'**
  String get startCapturing;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @waitForCompanyApproval.
  ///
  /// In en, this message translates to:
  /// **'Please wait for company admin approval, Contact your company admin.'**
  String get waitForCompanyApproval;

  /// No description provided for @complianceLabel.
  ///
  /// In en, this message translates to:
  /// **'COMPLIANCE'**
  String get complianceLabel;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cpeAssessmentReview.
  ///
  /// In en, this message translates to:
  /// **'CPE Assessment Review'**
  String get cpeAssessmentReview;

  /// No description provided for @cpeAssessmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review data and complete checklist to approve.'**
  String get cpeAssessmentSubtitle;

  /// No description provided for @deskInfo.
  ///
  /// In en, this message translates to:
  /// **'Desk Info'**
  String get deskInfo;

  /// No description provided for @deskIdLocation.
  ///
  /// In en, this message translates to:
  /// **'Desk ID / Location'**
  String get deskIdLocation;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @painAndSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Pain & Symptoms'**
  String get painAndSymptoms;

  /// No description provided for @painIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Pain Intensity'**
  String get painIntensityLabel;

  /// No description provided for @howDidYouReview.
  ///
  /// In en, this message translates to:
  /// **'How did you review this workstation?'**
  String get howDidYouReview;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @decisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get decisionLabel;

  /// No description provided for @commentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentLabel;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. this looks good I guess.'**
  String get commentHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @overallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall score:'**
  String get overallScore;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @needsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs improvement.'**
  String get needsImprovement;

  /// No description provided for @immediateCorrectRequired.
  ///
  /// In en, this message translates to:
  /// **'Immediate correction required!'**
  String get immediateCorrectRequired;

  /// No description provided for @scoreRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get scoreRed;

  /// No description provided for @scoreGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scoreGood;

  /// No description provided for @scoreModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get scoreModerate;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @loginAs.
  ///
  /// In en, this message translates to:
  /// **'Login as'**
  String get loginAs;

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectAccountType;

  /// No description provided for @cpe.
  ///
  /// In en, this message translates to:
  /// **'CPE'**
  String get cpe;

  /// No description provided for @ergonomistCpe.
  ///
  /// In en, this message translates to:
  /// **'Ergonomist / CPE'**
  String get ergonomistCpe;

  /// No description provided for @employeeEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Employee email is required'**
  String get employeeEmailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @pleaseSelectUserMode.
  ///
  /// In en, this message translates to:
  /// **'Please select a user mode'**
  String get pleaseSelectUserMode;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all the fields'**
  String get pleaseFillAllFields;

  /// No description provided for @pleaseEnterCompanyCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter company code'**
  String get pleaseEnterCompanyCode;

  /// No description provided for @allFieldsMustBeFilled.
  ///
  /// In en, this message translates to:
  /// **'All fields must be filled'**
  String get allFieldsMustBeFilled;

  /// No description provided for @pleaseFillAllRequirements.
  ///
  /// In en, this message translates to:
  /// **'Please fill all the requirements'**
  String get pleaseFillAllRequirements;

  /// No description provided for @pleaseSelectBodyRegion.
  ///
  /// In en, this message translates to:
  /// **'Please select body region'**
  String get pleaseSelectBodyRegion;

  /// No description provided for @passwordNotMatched.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatched;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @otpSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your email'**
  String get otpSentToEmail;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @loginFirst.
  ///
  /// In en, this message translates to:
  /// **'Login first'**
  String get loginFirst;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected!'**
  String get noImageSelected;

  /// No description provided for @noPdfAvailable.
  ///
  /// In en, this message translates to:
  /// **'No PDF available'**
  String get noPdfAvailable;

  /// No description provided for @noAnalysisDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No analysis data available'**
  String get noAnalysisDataAvailable;

  /// No description provided for @noPostureDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No posture data available'**
  String get noPostureDataAvailable;

  /// No description provided for @loadingAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'Loading analysis data...'**
  String get loadingAnalysisData;

  /// No description provided for @exportRosaReportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export ROSA Report (PDF)'**
  String get exportRosaReportPdf;

  /// No description provided for @userFallbackName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallbackName;

  /// No description provided for @noExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No Exercises Yet'**
  String get noExercisesYet;

  /// No description provided for @pleaseCompleteAssessmentFirst.
  ///
  /// In en, this message translates to:
  /// **'Please complete your assessment first'**
  String get pleaseCompleteAssessmentFirst;

  /// No description provided for @clinicalProjection.
  ///
  /// In en, this message translates to:
  /// **'Clinical Projection'**
  String get clinicalProjection;

  /// No description provided for @evidenceBasedPrediction.
  ///
  /// In en, this message translates to:
  /// **'Evidence-based prediction'**
  String get evidenceBasedPrediction;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @neckFlexion.
  ///
  /// In en, this message translates to:
  /// **'Neck Flexion'**
  String get neckFlexion;

  /// No description provided for @shoulderElevation.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Elevation'**
  String get shoulderElevation;

  /// No description provided for @elbowAngle.
  ///
  /// In en, this message translates to:
  /// **'Elbow Angle'**
  String get elbowAngle;

  /// No description provided for @wristDeviation.
  ///
  /// In en, this message translates to:
  /// **'Wrist Deviation'**
  String get wristDeviation;

  /// No description provided for @pelvicTilt.
  ///
  /// In en, this message translates to:
  /// **'Pelvic Tilt'**
  String get pelvicTilt;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get highPriority;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source:'**
  String get sourceLabel;

  /// No description provided for @recommendationsSentToHr.
  ///
  /// In en, this message translates to:
  /// **'Recommendations sent to HR'**
  String get recommendationsSentToHr;

  /// No description provided for @exerciseDetails.
  ///
  /// In en, this message translates to:
  /// **'Exercise Details'**
  String get exerciseDetails;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @painLevelVas.
  ///
  /// In en, this message translates to:
  /// **'Pain Level (VAS)'**
  String get painLevelVas;

  /// No description provided for @improvement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @musclesAddressed.
  ///
  /// In en, this message translates to:
  /// **'Muscles Addressed'**
  String get musclesAddressed;

  /// No description provided for @safetyNote.
  ///
  /// In en, this message translates to:
  /// **'Safety Note'**
  String get safetyNote;

  /// No description provided for @contraindications.
  ///
  /// In en, this message translates to:
  /// **'Contraindications'**
  String get contraindications;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @addSignature.
  ///
  /// In en, this message translates to:
  /// **'Add Signature'**
  String get addSignature;

  /// No description provided for @uploadSignature.
  ///
  /// In en, this message translates to:
  /// **'Upload Signature'**
  String get uploadSignature;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @objective.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get objective;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @incomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incomplete;

  /// No description provided for @pleaseAnswerAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please answer all questions'**
  String get pleaseAnswerAllQuestions;

  /// No description provided for @greatStart.
  ///
  /// In en, this message translates to:
  /// **'Great Start!'**
  String get greatStart;

  /// No description provided for @unlockedSmartNudges.
  ///
  /// In en, this message translates to:
  /// **'You\'ve unlocked smart learning nudges to help you progress.'**
  String get unlockedSmartNudges;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @goToElearning.
  ///
  /// In en, this message translates to:
  /// **'Go to E-Learning'**
  String get goToElearning;

  /// No description provided for @noPersonDetected.
  ///
  /// In en, this message translates to:
  /// **'No person detected'**
  String get noPersonDetected;

  /// No description provided for @perfectPosture.
  ///
  /// In en, this message translates to:
  /// **'Perfect posture'**
  String get perfectPosture;

  /// No description provided for @slightlySlouched.
  ///
  /// In en, this message translates to:
  /// **'Slightly slouched'**
  String get slightlySlouched;

  /// No description provided for @backNotStraight.
  ///
  /// In en, this message translates to:
  /// **'Back not straight'**
  String get backNotStraight;

  /// No description provided for @zeroToFourHours.
  ///
  /// In en, this message translates to:
  /// **'0-4 Hours'**
  String get zeroToFourHours;

  /// No description provided for @fourToSixHours.
  ///
  /// In en, this message translates to:
  /// **'4-6 Hours'**
  String get fourToSixHours;

  /// No description provided for @sixToEightHours.
  ///
  /// In en, this message translates to:
  /// **'6-8 Hours'**
  String get sixToEightHours;

  /// No description provided for @eightPlusHours.
  ///
  /// In en, this message translates to:
  /// **'8+ Hours'**
  String get eightPlusHours;

  /// No description provided for @everyOneHour.
  ///
  /// In en, this message translates to:
  /// **'Every 1 Hour'**
  String get everyOneHour;

  /// No description provided for @everyTwoHours.
  ///
  /// In en, this message translates to:
  /// **'Every 2 Hours'**
  String get everyTwoHours;

  /// No description provided for @everyThreeHours.
  ///
  /// In en, this message translates to:
  /// **'Every 3 Hours'**
  String get everyThreeHours;

  /// No description provided for @rarely.
  ///
  /// In en, this message translates to:
  /// **'Rarely'**
  String get rarely;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @uploadImageSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get uploadImageSuccessfully;

  /// No description provided for @userNameChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Username changed successfully'**
  String get userNameChangedSuccessfully;

  /// No description provided for @fetchingDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Data not found'**
  String get fetchingDataNotFound;

  /// No description provided for @elbows.
  ///
  /// In en, this message translates to:
  /// **'Elbows'**
  String get elbows;

  /// No description provided for @knees.
  ///
  /// In en, this message translates to:
  /// **'Knees'**
  String get knees;

  /// No description provided for @ankles.
  ///
  /// In en, this message translates to:
  /// **'Ankles'**
  String get ankles;

  /// No description provided for @hipsGlutes.
  ///
  /// In en, this message translates to:
  /// **'Hips/Glutes'**
  String get hipsGlutes;

  /// No description provided for @failedToProcessAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Failed to process analysis. Please try again.'**
  String get failedToProcessAnalysis;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @failedToFetchReports.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch reports'**
  String get failedToFetchReports;

  /// No description provided for @pleaseEnterValidOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid OTP'**
  String get pleaseEnterValidOtp;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select a language'**
  String get pleaseSelectLanguage;

  /// No description provided for @yourReportPdf.
  ///
  /// In en, this message translates to:
  /// **'Your report PDF'**
  String get yourReportPdf;

  /// No description provided for @failedToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit'**
  String get failedToSubmit;

  /// No description provided for @failedToParseResponse.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse response'**
  String get failedToParseResponse;

  /// No description provided for @moduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get moduleLabel;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well Done!'**
  String get wellDone;

  /// No description provided for @keepTrying.
  ///
  /// In en, this message translates to:
  /// **'Keep Trying!'**
  String get keepTrying;

  /// No description provided for @youPassedModule.
  ///
  /// In en, this message translates to:
  /// **'You passed Module {moduleId} successfully'**
  String youPassedModule(int moduleId);

  /// No description provided for @needAtLeast4Correct.
  ///
  /// In en, this message translates to:
  /// **'You need at least 4 correct answers to pass'**
  String get needAtLeast4Correct;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get privacyPolicySubtitle;

  /// No description provided for @ppDataCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Data We Collect'**
  String get ppDataCollectionTitle;

  /// No description provided for @ppDataCollectionContent.
  ///
  /// In en, this message translates to:
  /// **'We collect posture photos taken during assessments, personal information (name, email, employee ID), workplace details (desk location, department, role), pain and symptom data you report, and device sensor data used during photo capture for posture validation.'**
  String get ppDataCollectionContent;

  /// No description provided for @ppHowWeUseTitle.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Data'**
  String get ppHowWeUseTitle;

  /// No description provided for @ppHowWeUseContent.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to perform ISO 9241-5:2024 compliant posture analysis, generate personalized correction reports and exercise recommendations, track your posture improvement over time, and provide ergonomic assessments to your employer (business users only).'**
  String get ppHowWeUseContent;

  /// No description provided for @ppDataStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Data Storage & Security'**
  String get ppDataStorageTitle;

  /// No description provided for @ppDataStorageContent.
  ///
  /// In en, this message translates to:
  /// **'All posture photos and personal data are encrypted and stored on secure servers. Photos are retained for up to 12 months and automatically deleted after this period. You may request early deletion at any time. We use industry-standard encryption protocols to protect your data both in transit and at rest.'**
  String get ppDataStorageContent;

  /// No description provided for @ppYourRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Your Rights'**
  String get ppYourRightsTitle;

  /// No description provided for @ppYourRightsContent.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access all personal data we hold about you, request correction of inaccurate data, request deletion of your data at any time, withdraw consent for photo uploads, and export your assessment data in a portable format.'**
  String get ppYourRightsContent;

  /// No description provided for @ppDataSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Data Sharing'**
  String get ppDataSharingTitle;

  /// No description provided for @ppDataSharingContent.
  ///
  /// In en, this message translates to:
  /// **'For business users, anonymized posture assessment results and compliance scores may be shared with your employer\'s HR department. We do not sell your personal data to third parties. Data may be shared with certified ergonomic professionals (CPEs) assigned to review your assessment.'**
  String get ppDataSharingContent;

  /// No description provided for @ppContactTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Contact Us'**
  String get ppContactTitle;

  /// No description provided for @ppContactContent.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this privacy policy or wish to exercise your data rights, please contact your company administrator or reach out to our support team through the app.'**
  String get ppContactContent;

  /// No description provided for @workstation.
  ///
  /// In en, this message translates to:
  /// **'Workstation'**
  String get workstation;

  /// No description provided for @yourWorkstation.
  ///
  /// In en, this message translates to:
  /// **'Your Workstation'**
  String get yourWorkstation;

  /// No description provided for @workstationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few quick questions before we take the photo'**
  String get workstationSubtitle;

  /// No description provided for @canAdjustChairHeight.
  ///
  /// In en, this message translates to:
  /// **'Can you adjust your chair height?'**
  String get canAdjustChairHeight;

  /// No description provided for @enoughLegRoom.
  ///
  /// In en, this message translates to:
  /// **'Is there enough leg room under your desk?'**
  String get enoughLegRoom;

  /// No description provided for @chairHasLumbarSupport.
  ///
  /// In en, this message translates to:
  /// **'Does your chair have lumbar support?'**
  String get chairHasLumbarSupport;

  /// No description provided for @monitorDistanceFromEyes.
  ///
  /// In en, this message translates to:
  /// **'Monitor distance from eyes?'**
  String get monitorDistanceFromEyes;

  /// No description provided for @monitorDistance.
  ///
  /// In en, this message translates to:
  /// **'Monitor distance'**
  String get monitorDistance;

  /// No description provided for @monitorDistanceLessThan40cm.
  ///
  /// In en, this message translates to:
  /// **'Less than 40 cm'**
  String get monitorDistanceLessThan40cm;

  /// No description provided for @monitorDistance40To70cm.
  ///
  /// In en, this message translates to:
  /// **'40–70 cm'**
  String get monitorDistance40To70cm;

  /// No description provided for @monitorDistanceMoreThan70cm.
  ///
  /// In en, this message translates to:
  /// **'More than 70 cm'**
  String get monitorDistanceMoreThan70cm;

  /// No description provided for @feetRestingFlat.
  ///
  /// In en, this message translates to:
  /// **'Are your feet resting flat on the floor?'**
  String get feetRestingFlat;

  /// No description provided for @monitorDirectlyInFront.
  ///
  /// In en, this message translates to:
  /// **'Is your monitor positioned directly in front of you (not to the side)?'**
  String get monitorDirectlyInFront;

  /// No description provided for @chairHasArmrests.
  ///
  /// In en, this message translates to:
  /// **'Does your chair have armrests?'**
  String get chairHasArmrests;

  /// No description provided for @basedOnPostureAnalysisIso.
  ///
  /// In en, this message translates to:
  /// **'Based on your posture analysis and ISO 9241-5:2024 principles...'**
  String get basedOnPostureAnalysisIso;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'nl': return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
