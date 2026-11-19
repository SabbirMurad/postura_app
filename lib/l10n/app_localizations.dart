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

  /// No description provided for @workAbilityRecoveryOutlook.
  ///
  /// In en, this message translates to:
  /// **'Work Ability & Recovery Outlook'**
  String get workAbilityRecoveryOutlook;

  /// No description provided for @workAbilityRecoveryOutlookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These questions help us estimate the risk of longer-term problems and how your pain may affect work. Your answers remain private and make the recommendations more accurate.'**
  String get workAbilityRecoveryOutlookSubtitle;

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

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get startScan;

  /// No description provided for @startScanInfo.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a new set of suggestions and score, and your previous results will be replaced by the new ones.'**
  String get startScanInfo;

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
  /// **'We send a 6 digit verification code to your email.'**
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

  /// No description provided for @canAdjustChairHeightYes.
  ///
  /// In en, this message translates to:
  /// **'Can adjust chair height'**
  String get canAdjustChairHeightYes;

  /// No description provided for @cannotAdjustChairHeight.
  ///
  /// In en, this message translates to:
  /// **'Cannot adjust chair height'**
  String get cannotAdjustChairHeight;

  /// No description provided for @enoughLegRoomYes.
  ///
  /// In en, this message translates to:
  /// **'Enough leg room under desk'**
  String get enoughLegRoomYes;

  /// No description provided for @notEnoughLegRoom.
  ///
  /// In en, this message translates to:
  /// **'Not enough room under desk'**
  String get notEnoughLegRoom;

  /// No description provided for @chairHasLumbarSupportYes.
  ///
  /// In en, this message translates to:
  /// **'Chair has lumbar support'**
  String get chairHasLumbarSupportYes;

  /// No description provided for @chairHasLumbarSupportNo.
  ///
  /// In en, this message translates to:
  /// **'Chair does not have lumbar support'**
  String get chairHasLumbarSupportNo;

  /// No description provided for @feetFlatYes.
  ///
  /// In en, this message translates to:
  /// **'Feet resting flat on the floor'**
  String get feetFlatYes;

  /// No description provided for @feetFlatNo.
  ///
  /// In en, this message translates to:
  /// **'Feet not resting flat on the floor'**
  String get feetFlatNo;

  /// No description provided for @monitorInFrontYes.
  ///
  /// In en, this message translates to:
  /// **'Monitor positioned directly in front'**
  String get monitorInFrontYes;

  /// No description provided for @monitorInFrontNo.
  ///
  /// In en, this message translates to:
  /// **'Monitor is not positioned directly in front'**
  String get monitorInFrontNo;

  /// No description provided for @chairHasArmrestsYes.
  ///
  /// In en, this message translates to:
  /// **'Chair has armrests'**
  String get chairHasArmrestsYes;

  /// No description provided for @chairHasArmrestsNo.
  ///
  /// In en, this message translates to:
  /// **'Chair does not have armrests'**
  String get chairHasArmrestsNo;

  /// No description provided for @rosaSubScores.
  ///
  /// In en, this message translates to:
  /// **'ROSA Sub Scores'**
  String get rosaSubScores;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @workstationQuestions.
  ///
  /// In en, this message translates to:
  /// **'Workstation Questions'**
  String get workstationQuestions;

  /// No description provided for @whoAnswersWorkstationQuestions.
  ///
  /// In en, this message translates to:
  /// **'Who will answer the workstation questions?'**
  String get whoAnswersWorkstationQuestions;

  /// No description provided for @illAnswerThem.
  ///
  /// In en, this message translates to:
  /// **'I\'ll answer them'**
  String get illAnswerThem;

  /// No description provided for @myErgonomistWillAnswer.
  ///
  /// In en, this message translates to:
  /// **'My ergonomist will'**
  String get myErgonomistWillAnswer;

  /// No description provided for @photosOnlyExplanation.
  ///
  /// In en, this message translates to:
  /// **'You\'ll only take the photos. Your ergonomist will answer the workstation questions from them, and your result will appear once they\'ve finished.'**
  String get photosOnlyExplanation;

  /// No description provided for @photosOnlyReviewNote.
  ///
  /// In en, this message translates to:
  /// **'These photos will be sent to your ergonomist. Once they\'ve answered the workstation questions, your score and recommendations will appear in the app.'**
  String get photosOnlyReviewNote;

  /// No description provided for @sendToErgonomist.
  ///
  /// In en, this message translates to:
  /// **'Send to Ergonomist'**
  String get sendToErgonomist;

  /// No description provided for @waitingForErgonomist.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your ergonomist'**
  String get waitingForErgonomist;

  /// No description provided for @waitingForErgonomistBody.
  ///
  /// In en, this message translates to:
  /// **'Your photos have been sent. Your score, report, equipment and exercises will appear here once your ergonomist has answered the workstation questions.'**
  String get waitingForErgonomistBody;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @workstationReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer for the employee\'s workstation, using their photos.'**
  String get workstationReviewSubtitle;

  /// No description provided for @saveAnswers.
  ///
  /// In en, this message translates to:
  /// **'Save Answers'**
  String get saveAnswers;

  /// No description provided for @answerWorkstationQuestionsFirst.
  ///
  /// In en, this message translates to:
  /// **'Answer the workstation questions before submitting.'**
  String get answerWorkstationQuestionsFirst;

  /// No description provided for @workstationAnswered.
  ///
  /// In en, this message translates to:
  /// **'Workstation questions answered'**
  String get workstationAnswered;

  /// No description provided for @workstationNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'The employee left these questions to you'**
  String get workstationNotAnswered;

  /// No description provided for @workstationErgonomistHint.
  ///
  /// In en, this message translates to:
  /// **'Answer them from the photos. Submitting the review scores the assessment and shows the result to the employee.'**
  String get workstationErgonomistHint;

  /// No description provided for @answerWorkstationQuestions.
  ///
  /// In en, this message translates to:
  /// **'Answer Questions'**
  String get answerWorkstationQuestions;

  /// No description provided for @editAnswers.
  ///
  /// In en, this message translates to:
  /// **'Edit Answers'**
  String get editAnswers;

  /// No description provided for @needsYourAnswers.
  ///
  /// In en, this message translates to:
  /// **'Needs your answers'**
  String get needsYourAnswers;

  /// No description provided for @originalRosaScore.
  ///
  /// In en, this message translates to:
  /// **'Original score'**
  String get originalRosaScore;

  /// No description provided for @fromEmployeesAnswers.
  ///
  /// In en, this message translates to:
  /// **'From the employee\'s answers'**
  String get fromEmployeesAnswers;

  /// No description provided for @updatedRosaScore.
  ///
  /// In en, this message translates to:
  /// **'Updated score'**
  String get updatedRosaScore;

  /// No description provided for @updatedByErgonomist.
  ///
  /// In en, this message translates to:
  /// **'Updated by the ergonomist'**
  String get updatedByErgonomist;

  /// No description provided for @rosaUpdatedNote.
  ///
  /// In en, this message translates to:
  /// **'The ergonomist updated the workstation answers during the review. Recommendations are based on the updated score.'**
  String get rosaUpdatedNote;

  /// No description provided for @workstationAnsweredByEmployee.
  ///
  /// In en, this message translates to:
  /// **'Answered by the employee'**
  String get workstationAnsweredByEmployee;

  /// No description provided for @workstationReviseHint.
  ///
  /// In en, this message translates to:
  /// **'You can update the employee\'s answers once. Submitting the review re-calculates the score; the employee\'s original score is kept and shown next to it.'**
  String get workstationReviseHint;

  /// No description provided for @updateAnswersOnce.
  ///
  /// In en, this message translates to:
  /// **'Update Answers (once)'**
  String get updateAnswersOnce;

  /// No description provided for @workstationRevisionPending.
  ///
  /// In en, this message translates to:
  /// **'Updated answers ready. The score is re-calculated when you submit the review.'**
  String get workstationRevisionPending;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChanges;

  /// No description provided for @workstationAlreadyRevised.
  ///
  /// In en, this message translates to:
  /// **'These answers were already updated by the ergonomist. They can only be updated once.'**
  String get workstationAlreadyRevised;

  /// Answer chip for yes/no questions (workstation questionnaire, safety questions)
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get asmNo;

  /// Workstation questionnaire, section header
  ///
  /// In en, this message translates to:
  /// **'Front Photo'**
  String get asmSectionFrontPhoto;

  /// Workstation questionnaire, front photo section
  ///
  /// In en, this message translates to:
  /// **'Can a photo be taken from the front view?'**
  String get asmQuestionFrontPhotoPossible;

  /// Workstation questionnaire, section header
  ///
  /// In en, this message translates to:
  /// **'Chair'**
  String get asmSectionChair;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Chair height is adjustable'**
  String get asmQuestionChairHeightAdjustable;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Enough room under the desk to cross your legs'**
  String get asmQuestionUnderDeskSpace;

  /// Workstation questionnaire, chair section; followed by three answer chips
  ///
  /// In en, this message translates to:
  /// **'Seat pan depth (space behind your knees)'**
  String get asmQuestionSeatPanDepth;

  /// Seat pan depth answer: about 3 inches (approx. 8 cm) of space behind the knees is correct
  ///
  /// In en, this message translates to:
  /// **'~3 in (OK)'**
  String get asmSeatDepthOk;

  /// Seat pan depth answer: the seat is too deep
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get asmSeatDepthTooLong;

  /// Seat pan depth answer: the seat is too shallow
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get asmSeatDepthTooShort;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Seat pan depth is adjustable'**
  String get asmQuestionSeatPanAdjustable;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Armrests are adjustable'**
  String get asmQuestionArmrestsAdjustable;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Armrest surface is hard or damaged'**
  String get asmQuestionArmrestHardDamaged;

  /// Workstation questionnaire, chair section
  ///
  /// In en, this message translates to:
  /// **'Do you use the armrests while working (keyboard/mouse)?'**
  String get asmQuestionUsesArmrests;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Your elbows/forearms are supported by the armrests or work surface'**
  String get asmQuestionElbowsSupported;

  /// Workstation questionnaire, chair section (asked only without a front photo)
  ///
  /// In en, this message translates to:
  /// **'Armrests are too wide apart'**
  String get asmQuestionArmrestsTooWide;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Backrest is adjustable'**
  String get asmQuestionBackrestAdjustable;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Chair has a usable backrest that supports your back while working'**
  String get asmQuestionUsableBackrest;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Chair provides lumbar support that contacts your lower back while sitting normally'**
  String get asmQuestionLumbarSupport;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Both feet are flat on the floor or a footrest while typing'**
  String get asmQuestionFeetSupported;

  /// Workstation questionnaire, chair section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Desk/work surface is too high (shoulders shrug)'**
  String get asmQuestionWorkSurfaceTooHigh;

  /// Workstation questionnaire, section header
  ///
  /// In en, this message translates to:
  /// **'Monitor & Telephone'**
  String get asmSectionMonitorPhone;

  /// Workstation questionnaire, monitor section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Monitor position is adjustable'**
  String get asmQuestionMonitorAdjustable;

  /// Workstation questionnaire, monitor section; followed by Below / At eye level / Above chips
  ///
  /// In en, this message translates to:
  /// **'Top of the monitor relative to eye level'**
  String get asmQuestionMonitorTopVsEyeLevel;

  /// Answer: top of the monitor is below eye level
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get asmMonitorBelow;

  /// Answer: top of the monitor is at eye level
  ///
  /// In en, this message translates to:
  /// **'At eye level'**
  String get asmMonitorAtEyeLevel;

  /// Answer: top of the monitor is above eye level
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get asmMonitorAbove;

  /// Workstation questionnaire, monitor section. English wording is fixed; do not change.
  ///
  /// In en, this message translates to:
  /// **'Do you need to turn your head more than about 30 degrees (left or right) to see the monitor?'**
  String get asmQuestionNeckTurn;

  /// Workstation questionnaire, monitor section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Monitor is farther than arm\'s length away (>75cm)'**
  String get asmQuestionMonitorTooFar;

  /// Workstation questionnaire, monitor section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'There is glare on the screen'**
  String get asmQuestionScreenGlare;

  /// Workstation questionnaire, monitor section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'You have a document holder for paper references'**
  String get asmQuestionDocumentHolder;

  /// Workstation questionnaire, telephone section; followed by three answer chips
  ///
  /// In en, this message translates to:
  /// **'Desk phone usage'**
  String get asmQuestionDeskPhoneUsage;

  /// Desk phone answer: I don't use a desk phone
  ///
  /// In en, this message translates to:
  /// **'Don\'t use'**
  String get asmPhoneDontUse;

  /// Desk phone answer: with a headset or held in one hand
  ///
  /// In en, this message translates to:
  /// **'Headset/1-hand'**
  String get asmPhoneHeadsetOneHand;

  /// Desk phone answer: the phone is far away and I have to reach for it
  ///
  /// In en, this message translates to:
  /// **'Reach far'**
  String get asmPhoneReachFar;

  /// Workstation questionnaire, telephone section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'You cradle the phone between ear and shoulder'**
  String get asmQuestionPhoneCradle;

  /// Workstation questionnaire, telephone section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'You have a hands-free option (headset/speakerphone)'**
  String get asmQuestionHandsFreeOption;

  /// Workstation questionnaire, telephone section (supplemental question)
  ///
  /// In en, this message translates to:
  /// **'Do you hold/cradle the phone between your ear and shoulder during calls?'**
  String get asmQuestionPhoneCradleSupplemental;

  /// Workstation questionnaire, telephone section (supplemental question)
  ///
  /// In en, this message translates to:
  /// **'Do you have a hands-free option available for phone calls (headset, speakerphone, or similar)?'**
  String get asmQuestionHandsFreeSupplemental;

  /// Workstation questionnaire, section header
  ///
  /// In en, this message translates to:
  /// **'Mouse & Keyboard'**
  String get asmSectionMouseKeyboard;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Mouse and keyboard are on different surfaces/heights'**
  String get asmQuestionMouseKeyboardDifferentSurfaces;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'You use a pinch grip on the mouse'**
  String get asmQuestionMousePinchGrip;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'There is a palm rest in front of the mouse'**
  String get asmQuestionMousePalmRest;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Mouse position is adjustable'**
  String get asmQuestionMouseAdjustable;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Mouse is positioned far enough away that you have to reach for it'**
  String get asmQuestionMouseTooFar;

  /// Workstation questionnaire, mouse & keyboard section (asked only without a front photo)
  ///
  /// In en, this message translates to:
  /// **'Wrists deviate sideways while typing'**
  String get asmQuestionWristDeviation;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Keyboard is too high (shoulders shrug)'**
  String get asmQuestionKeyboardTooHigh;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'You frequently reach overhead for items'**
  String get asmQuestionReachingOverhead;

  /// Workstation questionnaire, mouse & keyboard section (yes/no statement)
  ///
  /// In en, this message translates to:
  /// **'Keyboard platform/tray is adjustable'**
  String get asmQuestionKeyboardPlatformAdjustable;

  /// Workstation questionnaire, section header
  ///
  /// In en, this message translates to:
  /// **'Daily Duration'**
  String get asmSectionDailyDuration;

  /// Workstation questionnaire, duration section; followed by three duration chips
  ///
  /// In en, this message translates to:
  /// **'How long do you typically work continuously at this desk?'**
  String get asmQuestionContinuousDeskTime;

  /// Continuous desk time answer
  ///
  /// In en, this message translates to:
  /// **'< 30 min'**
  String get asmDeskDurationUnder30Min;

  /// Continuous desk time answer
  ///
  /// In en, this message translates to:
  /// **'30-60 min'**
  String get asmDeskDuration30To60Min;

  /// Continuous desk time answer
  ///
  /// In en, this message translates to:
  /// **'> 1 hour'**
  String get asmDeskDurationOver1Hour;

  /// Medical red-flag screening screen title
  ///
  /// In en, this message translates to:
  /// **'A Few Safety Questions'**
  String get asmRedFlagTitle;

  /// Medical red-flag screening screen subtitle. The quoted Yes must match the Yes answer chip.
  ///
  /// In en, this message translates to:
  /// **'These help us make sure exercise is a safe option for you right now. Answer honestly — a \"Yes\" just means we point you to a healthcare professional instead.'**
  String get asmRedFlagSubtitle;

  /// Medical red-flag question (cauda equina sign); yes/no
  ///
  /// In en, this message translates to:
  /// **'New loss of bladder or bowel control'**
  String get asmRedFlagBladderBowel;

  /// Medical red-flag question (saddle anaesthesia); yes/no
  ///
  /// In en, this message translates to:
  /// **'Numbness in the saddle area (inner thighs, groin, or genitals)'**
  String get asmRedFlagSaddleNumbness;

  /// Medical red-flag question (progressive motor weakness); yes/no
  ///
  /// In en, this message translates to:
  /// **'New or worsening weakness in your legs or arms'**
  String get asmRedFlagLimbWeakness;

  /// Medical red-flag question (significant trauma); yes/no
  ///
  /// In en, this message translates to:
  /// **'A significant recent trauma (e.g. a fall, accident, or blow to your back)'**
  String get asmRedFlagRecentTrauma;

  /// Medical red-flag question (infection / immunosuppression); yes/no
  ///
  /// In en, this message translates to:
  /// **'Fever, a recent infection, or a weakened immune system along with back pain'**
  String get asmRedFlagFeverInfection;

  /// Medical red-flag question (cancer history); yes/no
  ///
  /// In en, this message translates to:
  /// **'A history of cancer, with new or worsening back/spine pain'**
  String get asmRedFlagCancerHistory;

  /// Medical red-flag question (unremitting / night pain); yes/no
  ///
  /// In en, this message translates to:
  /// **'Severe pain that doesn\'t ease up, especially at night'**
  String get asmRedFlagSevereNightPain;

  /// Work Ability & Recovery Outlook, slider question 1 (0-10)
  ///
  /// In en, this message translates to:
  /// **'How large is the risk that your current pain may become persistent or long-term?'**
  String get asmOutlookChronicityRisk;

  /// Slider low end (0)
  ///
  /// In en, this message translates to:
  /// **'No risk'**
  String get asmOutlookNoRisk;

  /// Slider high end (10)
  ///
  /// In en, this message translates to:
  /// **'Very large risk'**
  String get asmOutlookVeryLargeRisk;

  /// Work Ability & Recovery Outlook, slider question 2 (0-10)
  ///
  /// In en, this message translates to:
  /// **'What are the chances you will be working your normal duties in 3 months?'**
  String get asmOutlookReturnToWork;

  /// Slider low end (0)
  ///
  /// In en, this message translates to:
  /// **'No chance'**
  String get asmOutlookNoChance;

  /// Slider high end (10)
  ///
  /// In en, this message translates to:
  /// **'Very large chance'**
  String get asmOutlookVeryLargeChance;

  /// Work Ability & Recovery Outlook, slider statement 3 (0-10, first person)
  ///
  /// In en, this message translates to:
  /// **'An increase in pain is an indication that I should stop what I am doing until the pain decreases.'**
  String get asmOutlookFearAvoidance;

  /// Slider low end (0)
  ///
  /// In en, this message translates to:
  /// **'Completely disagree'**
  String get asmOutlookCompletelyDisagree;

  /// Slider high end (10)
  ///
  /// In en, this message translates to:
  /// **'Completely agree'**
  String get asmOutlookCompletelyAgree;

  /// Work Ability & Recovery Outlook, slider statement 4 (0-10, first person)
  ///
  /// In en, this message translates to:
  /// **'I can do light work (or normal light duties) for an hour.'**
  String get asmOutlookLightWork;

  /// Slider low end (0) for the light-work and sleep statements
  ///
  /// In en, this message translates to:
  /// **'Cannot do it because of the pain'**
  String get asmOutlookCannotBecauseOfPain;

  /// Slider high end (10) for the light-work and sleep statements
  ///
  /// In en, this message translates to:
  /// **'Can do it without the pain being a problem'**
  String get asmOutlookCanWithoutPainProblem;

  /// Work Ability & Recovery Outlook, slider statement 5 (0-10, first person)
  ///
  /// In en, this message translates to:
  /// **'I can sleep at night.'**
  String get asmOutlookSleep;

  /// Work Ability & Recovery Outlook, slider question 6 (0-10)
  ///
  /// In en, this message translates to:
  /// **'How much has your pain reduced your productivity or ability to work at full capacity in the past week?'**
  String get asmOutlookPresenteeism;

  /// Slider low end (0)
  ///
  /// In en, this message translates to:
  /// **'Not at all'**
  String get asmOutlookNotAtAll;

  /// Slider high end (10)
  ///
  /// In en, this message translates to:
  /// **'Extremely (unable to work normally)'**
  String get asmOutlookExtremely;

  /// Work Ability & Recovery Outlook, question 7; followed by day-range chips
  ///
  /// In en, this message translates to:
  /// **'In the last 12 months, how many work days have you missed because of similar pain or musculoskeletal problems?'**
  String get asmOutlookPreviousAbsence;

  /// Work Ability & Recovery Outlook, slider statement 8 (0-10, first person)
  ///
  /// In en, this message translates to:
  /// **'I feel I can get support or make reasonable adjustments at work if needed because of this pain.'**
  String get asmOutlookWorkplaceSupport;

  /// Slider low end (0)
  ///
  /// In en, this message translates to:
  /// **'Strongly disagree'**
  String get asmOutlookStronglyDisagree;

  /// Slider high end (10)
  ///
  /// In en, this message translates to:
  /// **'Strongly agree'**
  String get asmOutlookStronglyAgree;

  /// Toast on the body region screen when the height field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get asmPleaseEnterHeight;

  /// Toast on the body region screen when the height is out of range
  ///
  /// In en, this message translates to:
  /// **'Height must be between 50 and 250 cm'**
  String get asmHeightRange;

  /// ROSA sub-score status badge (score 0)
  ///
  /// In en, this message translates to:
  /// **'Not assessed'**
  String get asmRiskNotAssessed;

  /// ROSA sub-score status badge
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get asmRiskHigh;

  /// ROSA sub-score status badge
  ///
  /// In en, this message translates to:
  /// **'Review needed'**
  String get asmRiskReviewNeeded;

  /// Final ROSA score label (7-10)
  ///
  /// In en, this message translates to:
  /// **'High risk — immediate action required'**
  String get asmFinalRiskHigh;

  /// Final ROSA score label (4-6)
  ///
  /// In en, this message translates to:
  /// **'Moderate risk — further investigation'**
  String get asmFinalRiskModerate;

  /// Final ROSA score label (1-3)
  ///
  /// In en, this message translates to:
  /// **'Low risk — no immediate action needed'**
  String get asmFinalRiskLow;

  /// ROSA action level (score 7-10)
  ///
  /// In en, this message translates to:
  /// **'Level 3 — Action required as soon as possible'**
  String get asmActionLevel3;

  /// ROSA action level (score 4-6)
  ///
  /// In en, this message translates to:
  /// **'Level 2 — Further investigation needed'**
  String get asmActionLevel2;

  /// ROSA action level (score 1-3)
  ///
  /// In en, this message translates to:
  /// **'Level 1 — No immediate action needed'**
  String get asmActionLevel1;

  /// Caption of a side-view capture on the analysis result screen
  ///
  /// In en, this message translates to:
  /// **'Side view {number}'**
  String asmSideViewNumber(int number);

  /// Caption of the front-view capture on the analysis result screen
  ///
  /// In en, this message translates to:
  /// **'Front view'**
  String get asmFrontView;

  /// Measured angle label on a capture card
  ///
  /// In en, this message translates to:
  /// **'Knee'**
  String get asmMetricKnee;

  /// Measured angle label on a capture card
  ///
  /// In en, this message translates to:
  /// **'Trunk'**
  String get asmMetricTrunk;

  /// Measured angle label on a capture card
  ///
  /// In en, this message translates to:
  /// **'Elbow'**
  String get asmMetricElbow;

  /// Label for the detected neck posture on a capture card
  ///
  /// In en, this message translates to:
  /// **'Neck state'**
  String get asmMetricNeckState;

  /// How reliably the lower body (knee angle) was detected; value is High or Low
  ///
  /// In en, this message translates to:
  /// **'Lower body confidence'**
  String get asmMetricLowerBodyConfidence;

  /// Lower body detection confidence value
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get asmConfidenceHigh;

  /// Lower body detection confidence value
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get asmConfidenceLow;

  /// Measured angle label on the front-view capture card
  ///
  /// In en, this message translates to:
  /// **'Elbow abduction'**
  String get asmMetricElbowAbduction;

  /// Measured angle label on the front-view capture card
  ///
  /// In en, this message translates to:
  /// **'Wrist deviation'**
  String get asmMetricWristDeviation;

  /// Shown instead of an angle that could not be measured
  ///
  /// In en, this message translates to:
  /// **'Not measured'**
  String get asmNotMeasured;

  /// Button on the analysis result screen
  ///
  /// In en, this message translates to:
  /// **'Submit Result'**
  String get asmSubmitResult;

  /// Toast on the photo capture guide when the native camera returned no side photos
  ///
  /// In en, this message translates to:
  /// **'Capture did not complete. Please try again.'**
  String get capCaptureIncomplete;

  /// Toast on the photo capture guide when the native camera screen reported an error
  ///
  /// In en, this message translates to:
  /// **'Posture detection failed.'**
  String get capDetectionFailed;

  /// Login screen toast when a non-employee taps the SSO button
  ///
  /// In en, this message translates to:
  /// **'SSO sign-in is for company employees.'**
  String get genSsoForEmployeesOnly;

  /// Login screen, title of the dialog asking for the company code before SSO
  ///
  /// In en, this message translates to:
  /// **'Company code'**
  String get genCompanyCode;

  /// Login screen divider between password login and SSO
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get genOr;

  /// Login screen SSO button
  ///
  /// In en, this message translates to:
  /// **'Continue with SSO'**
  String get genContinueWithSso;

  /// Exercise list intro card title (also in the PDF report)
  ///
  /// In en, this message translates to:
  /// **'A comfortable movement break, one step at a time'**
  String get genExerciseIntroTitle;

  /// Exercise list intro card, first paragraph (also in the PDF report)
  ///
  /// In en, this message translates to:
  /// **'Use the exercises selected for you by the app—you do not need to complete this whole library. Start gently, breathe normally and choose a range that feels comfortable. A small, controlled movement is enough; there is no need to force a stretch.'**
  String get genExerciseIntroBody;

  /// Exercise intro card, bold lead-in of a paragraph
  ///
  /// In en, this message translates to:
  /// **'Your exercise amount'**
  String get genExerciseIntroAmountTitle;

  /// Exercise intro card paragraph
  ///
  /// In en, this message translates to:
  /// **'Follow the sets, repetitions or hold time shown in your programme. The descriptions below explain how to move, not a second amount to complete.'**
  String get genExerciseIntroAmountBody;

  /// Exercise intro card, bold lead-in of a paragraph
  ///
  /// In en, this message translates to:
  /// **'The highlighted body area'**
  String get genExerciseIntroAreaTitle;

  /// Exercise intro card paragraph
  ///
  /// In en, this message translates to:
  /// **'The red area is an approximate guide, not a diagnosis or a promise that you will feel the movement in exactly that spot.'**
  String get genExerciseIntroAreaBody;

  /// Exercise intro card lead-in and exercise detail section title
  ///
  /// In en, this message translates to:
  /// **'When to stop'**
  String get genExerciseIntroStopTitle;

  /// Exercise intro card paragraph
  ///
  /// In en, this message translates to:
  /// **'Stop for sharp pain, dizziness, numbness, tingling or symptoms that get worse. If symptoms continue after stopping, seek professional advice. Follow the specific safety advice for each exercise below.'**
  String get genExerciseIntroStopBody;

  /// Exercise detail, recommended dose. duration comes from the server, e.g. "10–15 seconds"
  ///
  /// In en, this message translates to:
  /// **'{sets, plural, =1{1 set} other{{sets} sets}}, hold {duration}'**
  String genExerciseSetsHold(int sets, String duration);

  /// Exercise detail, "Your programme" section
  ///
  /// In en, this message translates to:
  /// **'Follow the sets, repetitions or hold time shown in your personalised programme.'**
  String get genProgrammeNote;

  /// Exercise detail section title
  ///
  /// In en, this message translates to:
  /// **'Muscles / body area'**
  String get genMusclesBodyArea;

  /// Exercise detail section title
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get genHowToDoIt;

  /// Exercise detail section title
  ///
  /// In en, this message translates to:
  /// **'Why this helps'**
  String get genWhyThisHelps;

  /// Exercise detail section title
  ///
  /// In en, this message translates to:
  /// **'Your programme'**
  String get genYourProgramme;

  /// Exercise detail, pain score of the body region
  ///
  /// In en, this message translates to:
  /// **'Pain level (VAS): {vas} / 10'**
  String genPainLevelVasOutOf10(int vas);

  /// Exercise detail section title
  ///
  /// In en, this message translates to:
  /// **'When not to use / when to stop'**
  String get genWhenNotToUseWhenToStop;

  /// Exercise programme intensity badge (also in PDF)
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get genTierGentle;

  /// Exercise programme intensity badge (also in PDF); must differ from genTierGentle, the code compares them
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get genTierModerate;

  /// Exercise programme description for the moderate tier (also in PDF)
  ///
  /// In en, this message translates to:
  /// **'Balanced programme to reduce discomfort and improve mobility.'**
  String get genTierModerateMessage;

  /// Exercise programme description for the gentle tier (also in PDF)
  ///
  /// In en, this message translates to:
  /// **'Gentle programme to relieve tension and build resilience.'**
  String get genTierGentleMessage;

  /// Exercise programme frequency line (also in PDF)
  ///
  /// In en, this message translates to:
  /// **'3× per week · {minutes} min sessions'**
  String genTierFrequency(int minutes);

  /// Exercise screen empty state title when exercises are stopped after screening
  ///
  /// In en, this message translates to:
  /// **'Please Check In With a Professional'**
  String get genCheckInWithProfessional;

  /// Exercise screen empty state, fallback when the server sends no message
  ///
  /// In en, this message translates to:
  /// **'Based on your screening answers, please consult a healthcare professional before starting exercises.'**
  String get genConsultBeforeExercises;

  /// Exercise screen banner when the CPE should review the programme
  ///
  /// In en, this message translates to:
  /// **'Based on your answers, we recommend keeping these gentle and reviewing them with your CPE or a healthcare professional. Stop immediately if any exercise increases your symptoms.'**
  String get genKeepExercisesGentleCpe;

  /// Splash screen tagline under the logo, shown in capitals; keep the line break
  ///
  /// In en, this message translates to:
  /// **'LET\'S IMPROVE YOUR\nPOSTURE'**
  String get genSplashTagline;

  /// Verify email screen, resend button while the cooldown runs
  ///
  /// In en, this message translates to:
  /// **'Resend code ({seconds}s)'**
  String genResendCodeCountdown(int seconds);

  /// Bottom navigation tab for equipment recommendations
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get genEquipment;

  /// Password rule error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get genPasswordTooShort;

  /// Password rule error
  ///
  /// In en, this message translates to:
  /// **'Password must be at most 128 characters.'**
  String get genPasswordTooLong;

  /// Password rule error
  ///
  /// In en, this message translates to:
  /// **'Password must contain both letters and numbers.'**
  String get genPasswordNeedsLettersAndNumbers;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get genMonthJan;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get genMonthFeb;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get genMonthMar;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get genMonthApr;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get genMonthMay;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get genMonthJun;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get genMonthJul;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get genMonthAug;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get genMonthSep;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get genMonthOct;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get genMonthNov;

  /// Short month name in dates, e.g. "18 Nov 2026"
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get genMonthDec;

  /// Date format: two-digit day, short month name, year. Reorder for the language.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year}'**
  String genDateDayMonthYear(String day, String month, String year);

  /// E-learning certificate card title
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get genCertificate;

  /// E-learning certificate card while locked
  ///
  /// In en, this message translates to:
  /// **'Complete all the modules to claim your certificate.'**
  String get genCompleteModulesForCertificate;

  /// E-learning certificate expiry line
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String genValidUntilDate(String date);

  /// E-learning certificate status when there is no expiry date
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get genValid;

  /// E-learning certificate badge, capitals
  ///
  /// In en, this message translates to:
  /// **'VALID'**
  String get genValidBadge;

  /// E-learning certificate badge, capitals
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get genExpiredBadge;

  /// E-learning certificate card button
  ///
  /// In en, this message translates to:
  /// **'View Certificate'**
  String get genViewCertificate;

  /// E-learning certificate card when expired
  ///
  /// In en, this message translates to:
  /// **'Your certificate has expired. Complete all modules again to renew it.'**
  String get genCertificateExpiredBody;

  /// Certificate details, label before the user name (keep the trailing space)
  ///
  /// In en, this message translates to:
  /// **'Name: '**
  String get genNameLabel;

  /// Certificate details, label before the employee ID (keep the trailing space)
  ///
  /// In en, this message translates to:
  /// **'ID: '**
  String get genIdLabel;

  /// Certificate details, above the date a module was passed
  ///
  /// In en, this message translates to:
  /// **'Passed On'**
  String get genPassedOn;

  /// Certificate details label
  ///
  /// In en, this message translates to:
  /// **'Certificate ID'**
  String get genCertificateId;

  /// Certificate details label above a date
  ///
  /// In en, this message translates to:
  /// **'Issued on'**
  String get genIssuedOn;

  /// Certificate details label above a date
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get genValidUntil;

  /// Certificate details button to download the PDF
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get genDownload;

  /// E-learning quiz screen title
  ///
  /// In en, this message translates to:
  /// **'Module {number}'**
  String genModuleNumber(int number);

  /// E-learning quiz snackbar when not all questions are answered
  ///
  /// In en, this message translates to:
  /// **'Incomplete: Please answer all questions'**
  String get genIncompleteAnswerAllQuestions;

  /// E-learning quiz question with its number; Q = question. question is module content
  ///
  /// In en, this message translates to:
  /// **'Q{number}. {question}'**
  String genQuizQuestionNumbered(int number, String question);

  /// Network error
  ///
  /// In en, this message translates to:
  /// **'No internet connection found!'**
  String get genNoInternetConnection;

  /// Network error when the login token cannot be refreshed
  ///
  /// In en, this message translates to:
  /// **'Session expired, Please sign in again!'**
  String get genSessionExpired;

  /// Network error
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get genRequestTimedOut;

  /// Network error during a file upload
  ///
  /// In en, this message translates to:
  /// **'Upload timed out. Please try again.'**
  String get genUploadTimedOut;

  /// Generic network error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genSomethingWentWrongTryAgain;

  /// Generic server error when the server sends no message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genSomethingWentWrongDot;

  /// Server error 404
  ///
  /// In en, this message translates to:
  /// **'Endpoint not found!'**
  String get genEndpointNotFound;

  /// Toast when the device is offline
  ///
  /// In en, this message translates to:
  /// **'Failed to establish connection, please check your internet connection'**
  String get genCheckInternetConnection;

  /// Toast when the connectivity check fails
  ///
  /// In en, this message translates to:
  /// **'Unable to check network status. Please try again.'**
  String get genNetworkStatusUnavailable;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Nice work starting Module 1. Take 30 seconds to notice any awkward posture or long static sitting — then continue with Module 2 when you have a moment.'**
  String get genNudgeModule1a;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen the basics of ergonomics in Module 1. One small step: check your posture now and plan when you\'ll start Module 2.'**
  String get genNudgeModule1b;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'You practiced neutral sitting in Module 2. Today, check your feet, hips, and head position — then move on to Module 3 to optimise your screen and devices.'**
  String get genNudgeModule2a;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Module 2 tip in action: sit tall with your back supported and head over shoulders. When you\'re ready, open Module 3 to fine-tune your screen setup.'**
  String get genNudgeModule2b;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'You learned about screens, keyboard, and mouse in Module 3. Do a quick check now, then continue with Module 4 to improve light and microbreaks.'**
  String get genNudgeModule3a;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Screen height, distance, and mouse position make a big difference. Adjust one thing from Module 3 today, and finish Module 4 when you have 5 minutes.'**
  String get genNudgeModule3b;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached Module 4: light, noise, and microbreaks. Take a 20–30 second microbreak now — then continue to Module 5 to cover lifting basics.'**
  String get genNudgeModule4a;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Short microbreaks from Module 4 help your focus. Do one now and schedule time to complete Module 5 for safe handling and lifting.'**
  String get genNudgeModule4b;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen safe lifting in Module 5. Keep loads close and avoid twisting. When your schedule allows, start Module 6 to apply ergonomics at home or remotely.'**
  String get genNudgeModule5a;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Think of your last lift at work: did you keep the load close and turn with your feet? When ready, open Module 6 to improve your hybrid/remote setup.'**
  String get genNudgeModule5b;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Hybrid and remote tips from Module 6 work best with regular movement. Stand up for one call today, then complete Module 7 to learn your daily preventive routine.'**
  String get genNudgeModule6a;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Raised laptop, external keyboard, and short standing breaks — apply one Module 6 tip now and then finish Module 7 to build a simple daily routine.'**
  String get genNudgeModule6b;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'You\'re close to the finish line. Use one Module 7 stretch (neck, shoulders, or wrists) now, and complete your remaining quiz steps to get your certificate.'**
  String get genNudgeModule7a;

  /// E-learning reminder nudge shown as an in-app banner
  ///
  /// In en, this message translates to:
  /// **'Simple stretches from Module 7 help prevent stiffness. Do one round now and finalise any open module quizzes to earn your ergonomics certificate.'**
  String get genNudgeModule7b;

  /// Android notification channel name, shown in the phone's notification settings
  ///
  /// In en, this message translates to:
  /// **'High Importance Notifications'**
  String get genNotificationChannelName;

  /// Android notification channel description, shown in the phone's notification settings
  ///
  /// In en, this message translates to:
  /// **'This channel is used for important notifications.'**
  String get genNotificationChannelDescription;

  /// Push notification action button
  ///
  /// In en, this message translates to:
  /// **'Follow Back'**
  String get genFollowBack;

  /// Push notification action button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get genAccept;

  /// Push notification action button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get genReject;

  /// Push notification action button
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get genReply;

  /// Push notification reply field hint
  ///
  /// In en, this message translates to:
  /// **'Type your reply'**
  String get genTypeYourReply;

  /// Push notification action button
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get genMarkAsRead;

  /// Toast when the profile picture upload fails
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get genFailedToUploadImage;

  /// Login toast
  ///
  /// In en, this message translates to:
  /// **'SSO is not enabled for this company.'**
  String get genSsoNotEnabled;

  /// Login toast
  ///
  /// In en, this message translates to:
  /// **'SSO is not configured for this company.'**
  String get genSsoNotConfigured;

  /// Login toast when the server sends no message
  ///
  /// In en, this message translates to:
  /// **'SSO sign-in failed.'**
  String get genSsoSignInFailed;

  /// Small badge on an exercise card with the pain score (VAS = visual analogue scale; Spanish EVA)
  ///
  /// In en, this message translates to:
  /// **'VAS {vas}'**
  String genVasBadge(int vas);

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Left Shoulder'**
  String get mdlRegionLeftShoulder;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Right Shoulder'**
  String get mdlRegionRightShoulder;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Left Wrist'**
  String get mdlRegionLeftWrist;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Right Wrist'**
  String get mdlRegionRightWrist;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Left Elbow'**
  String get mdlRegionLeftElbow;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Right Elbow'**
  String get mdlRegionRightElbow;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Left Hip'**
  String get mdlRegionLeftHip;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Right Hip'**
  String get mdlRegionRightHip;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Left Knee'**
  String get mdlRegionLeftKnee;

  /// Body region for pain reporting
  ///
  /// In en, this message translates to:
  /// **'Right Knee'**
  String get mdlRegionRightKnee;

  /// Body region tile on the home screen risk grid
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get mdlRegionShoulder;

  /// Body region tile on the home screen risk grid
  ///
  /// In en, this message translates to:
  /// **'Wrist'**
  String get mdlRegionWrist;

  /// Risk level badge on a body region tile (shown in capitals)
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get mdlRiskHigh;

  /// Pain duration option
  ///
  /// In en, this message translates to:
  /// **'No pain'**
  String get mdlPainDurationNone;

  /// Pain duration option
  ///
  /// In en, this message translates to:
  /// **'1-4 weeks'**
  String get mdlPainDuration1To4Weeks;

  /// Pain duration option
  ///
  /// In en, this message translates to:
  /// **'6-12 weeks'**
  String get mdlPainDuration6To12Weeks;

  /// Pain duration option
  ///
  /// In en, this message translates to:
  /// **'1-3 months'**
  String get mdlPainDuration1To3Months;

  /// Pain duration option
  ///
  /// In en, this message translates to:
  /// **'3-6 months'**
  String get mdlPainDuration3To6Months;

  /// Pain duration option
  ///
  /// In en, this message translates to:
  /// **'More than 6 months'**
  String get mdlPainDurationMoreThan6Months;

  /// Optional symptom option
  ///
  /// In en, this message translates to:
  /// **'Numbness or tingling'**
  String get mdlSymptomNumbness;

  /// Optional symptom option
  ///
  /// In en, this message translates to:
  /// **'Swelling'**
  String get mdlSymptomSwelling;

  /// Optional symptom option
  ///
  /// In en, this message translates to:
  /// **'Reduced range of motion'**
  String get mdlSymptomReducedRange;

  /// Optional symptom option
  ///
  /// In en, this message translates to:
  /// **'Headaches'**
  String get mdlSymptomHeadaches;

  /// Optional symptom option
  ///
  /// In en, this message translates to:
  /// **'Eye strain'**
  String get mdlSymptomEyeStrain;

  /// Work days missed in the last 12 months (Work Ability & Recovery Outlook)
  ///
  /// In en, this message translates to:
  /// **'0 days'**
  String get mdlAbsenceZeroDays;

  /// Work days missed in the last 12 months (Work Ability & Recovery Outlook)
  ///
  /// In en, this message translates to:
  /// **'1-5 days'**
  String get mdlAbsence1To5Days;

  /// Work days missed in the last 12 months (Work Ability & Recovery Outlook)
  ///
  /// In en, this message translates to:
  /// **'6-15 days'**
  String get mdlAbsence6To15Days;

  /// Work days missed in the last 12 months (Work Ability & Recovery Outlook)
  ///
  /// In en, this message translates to:
  /// **'16-30 days'**
  String get mdlAbsence16To30Days;

  /// Work days missed in the last 12 months (Work Ability & Recovery Outlook)
  ///
  /// In en, this message translates to:
  /// **'More than 30 days'**
  String get mdlAbsenceMoreThan30Days;

  /// Answer to a yes/no screening question (ergonomist review)
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get mdlNo;

  /// Medical red-flag screening question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'New loss of bladder or bowel control'**
  String get mdlRedFlagBladderBowel;

  /// Medical red-flag screening question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'Numbness in the saddle area (inner thighs, groin, or genitals)'**
  String get mdlRedFlagSaddleNumbness;

  /// Medical red-flag screening question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'New or worsening weakness in your legs or arms'**
  String get mdlRedFlagWeakness;

  /// Medical red-flag screening question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'A significant recent trauma (e.g. a fall, accident, or blow to your back)'**
  String get mdlRedFlagTrauma;

  /// Medical red-flag screening question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'Fever, a recent infection, or a weakened immune system along with back pain'**
  String get mdlRedFlagFeverInfection;

  /// Medical red-flag screening question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'A history of cancer, with new or worsening back/spine pain'**
  String get mdlRedFlagCancerHistory;

  /// Medical red-flag screening question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'Severe pain that doesn\'t ease up, especially at night'**
  String get mdlRedFlagNightPain;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'How large is the risk that your current pain may become persistent or long-term?'**
  String get mdlRecoveryQChronicityRisk;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'What are the chances you will be working your normal duties in 3 months?'**
  String get mdlRecoveryQRtwExpectancy;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'An increase in pain is an indication that I should stop what I am doing until the pain decreases.'**
  String get mdlRecoveryQFearAvoidance;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'I can do light work (or normal light duties) for an hour.'**
  String get mdlRecoveryQLightWork;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'I can sleep at night.'**
  String get mdlRecoveryQSleep;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'How much has your pain reduced your productivity or ability to work at full capacity in the past week?'**
  String get mdlRecoveryQPresenteeism;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'I feel I can get support or make reasonable adjustments at work if needed because of this pain.'**
  String get mdlRecoveryQWorkplaceSupport;

  /// Work Ability & Recovery Outlook question, shown on the ergonomist's review of the employee's answers
  ///
  /// In en, this message translates to:
  /// **'In the last 12 months, how many work days have you missed because of similar pain or musculoskeletal problems?'**
  String get mdlRecoveryQPreviousAbsence;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'No risk'**
  String get mdlRecoveryScaleNoRisk;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Very large risk'**
  String get mdlRecoveryScaleVeryLargeRisk;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'No chance'**
  String get mdlRecoveryScaleNoChance;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Very large chance'**
  String get mdlRecoveryScaleVeryLargeChance;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Completely disagree'**
  String get mdlRecoveryScaleCompletelyDisagree;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Completely agree'**
  String get mdlRecoveryScaleCompletelyAgree;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Cannot do it because of the pain'**
  String get mdlRecoveryScaleCannotBecausePain;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Can do it without the pain being a problem'**
  String get mdlRecoveryScaleCanWithoutPainProblem;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Not at all'**
  String get mdlRecoveryScaleNotAtAll;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Extremely (unable to work normally)'**
  String get mdlRecoveryScaleExtremely;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Strongly disagree'**
  String get mdlRecoveryScaleStronglyDisagree;

  /// End label of a 0-10 answer scale (shown as "0 = ... · 10 = ...")
  ///
  /// In en, this message translates to:
  /// **'Strongly agree'**
  String get mdlRecoveryScaleStronglyAgree;

  /// Neck posture measured from the side photo (value next to "Neck state")
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get mdlNeckNeutral;

  /// Neck posture measured from the side photo (value next to "Neck state")
  ///
  /// In en, this message translates to:
  /// **'Forward head'**
  String get mdlNeckForwardHead;

  /// Neck posture measured from the side photo (value next to "Neck state")
  ///
  /// In en, this message translates to:
  /// **'Mild flexion'**
  String get mdlNeckMildFlexion;

  /// Neck posture measured from the side photo (value next to "Neck state")
  ///
  /// In en, this message translates to:
  /// **'Severe flexion'**
  String get mdlNeckSevereFlexion;

  /// Neck posture measured from the side photo (value next to "Neck state")
  ///
  /// In en, this message translates to:
  /// **'Head back'**
  String get mdlNeckHeadBack;

  /// Fallback link text on an equipment card when the server sends none
  ///
  /// In en, this message translates to:
  /// **'View related action'**
  String get mdlViewRelatedAction;

  /// Error toast when submitting a scan without photos
  ///
  /// In en, this message translates to:
  /// **'No capture to submit'**
  String get mdlNoCaptureToSubmit;

  /// Error toast when the scan photos could not be uploaded
  ///
  /// In en, this message translates to:
  /// **'Failed to upload images'**
  String get mdlFailedToUploadImages;

  /// ROSA posture guidance (Action Report) screen, title
  ///
  /// In en, this message translates to:
  /// **'ROSA Posture Guidance'**
  String get mdlRosaPostureGuidance;

  /// ROSA posture guidance (Action Report) screen, subtitle
  ///
  /// In en, this message translates to:
  /// **'Directional adjustments to improve your ergonomic setup'**
  String get mdlRosaPostureGuidanceSubtitle;

  /// ROSA posture guidance (Action Report) screen, report header. tierName comes from the server.
  ///
  /// In en, this message translates to:
  /// **'Tier {tier} - {tierName} | ROSA {score}/10'**
  String mdlTierHeader(int tier, String tierName, int score);

  /// ROSA posture guidance (Action Report) screen. driver comes from the server.
  ///
  /// In en, this message translates to:
  /// **'Main risk driver: {driver}'**
  String mdlMainRiskDriver(String driver);

  /// ROSA posture guidance (Action Report) screen, section heading
  ///
  /// In en, this message translates to:
  /// **'Priority Findings'**
  String get mdlPriorityFindings;

  /// ROSA posture guidance (Action Report) screen, section heading
  ///
  /// In en, this message translates to:
  /// **'Supplemental CPE Findings'**
  String get mdlSupplementalCpeFindings;

  /// ROSA posture guidance (Action Report) screen, section heading
  ///
  /// In en, this message translates to:
  /// **'What You Can Do Right Now'**
  String get mdlWhatYouCanDoNow;

  /// ROSA posture guidance (Action Report) screen, section heading
  ///
  /// In en, this message translates to:
  /// **'When Equipment Helps'**
  String get mdlWhenEquipmentHelps;

  /// ROSA posture guidance (Action Report) screen, link
  ///
  /// In en, this message translates to:
  /// **'View Equipment Recommendations'**
  String get mdlViewEquipmentRecommendations;

  /// ROSA posture guidance (Action Report) screen, section heading
  ///
  /// In en, this message translates to:
  /// **'General Workstation Habits'**
  String get mdlGeneralWorkstationHabits;

  /// Character counter under a text field
  ///
  /// In en, this message translates to:
  /// **'text limit {current}/{max}'**
  String mdlTextLimit(int current, int max);

  /// Warning shown at startup on a rooted/jailbroken device, title
  ///
  /// In en, this message translates to:
  /// **'This device may be rooted'**
  String get mdlDeviceRootedTitle;

  /// Warning shown at startup on a rooted/jailbroken device, body
  ///
  /// In en, this message translates to:
  /// **'Postura found signs that this device is rooted or jailbroken. Other apps on it may be able to read your assessment data and photos. Use an unmodified device if you can.'**
  String get mdlDeviceRootedBody;

  /// Warning shown at startup on a rooted/jailbroken device, button
  ///
  /// In en, this message translates to:
  /// **'I understand, continue'**
  String get mdlIUnderstandContinue;

  /// E-learning module card, module number
  ///
  /// In en, this message translates to:
  /// **'Module {number}'**
  String mdlModuleNumber(int number);

  /// Greeting at the top of the home screen
  ///
  /// In en, this message translates to:
  /// **'Hi {name} 👋'**
  String mdlHiName(String name);

  /// Height field before a scan, label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mdlHeight;

  /// Height field before a scan, hint
  ///
  /// In en, this message translates to:
  /// **'Height in cm (e.g. 175)'**
  String get mdlHeightHintCm;

  /// Height field before a scan, error toast
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get mdlPleaseEnterHeight;

  /// Height field before a scan, error toast
  ///
  /// In en, this message translates to:
  /// **'Height must be between 50 and 250 cm'**
  String get mdlHeightOutOfRange;

  /// Shown over a blurred placeholder when an image fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load image'**
  String get mdlCouldNotLoadImage;

  /// Banner shown when the Recovery Outlook (chronicity level) is Elevated, one-line version
  ///
  /// In en, this message translates to:
  /// **'Recovery Outlook: Elevated — early support recommended'**
  String get mdlRecoveryOutlookElevatedCompact;

  /// Banner shown when the Recovery Outlook (chronicity level) is Elevated, title
  ///
  /// In en, this message translates to:
  /// **'Recovery Outlook: Elevated'**
  String get mdlRecoveryOutlookElevated;

  /// Banner shown when the Recovery Outlook (chronicity level) is Elevated, body
  ///
  /// In en, this message translates to:
  /// **'Your answers indicate a higher risk that the current pain could become longer-term. Early targeted support is recommended in addition to the workstation adjustments below.'**
  String get mdlRecoveryOutlookElevatedBody;

  /// ROSA score tile when no valid score could be measured
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get mdlNotAvailable;

  /// Subject line of the share sheet when exporting the PDF report (home screen)
  ///
  /// In en, this message translates to:
  /// **'Postura Assessment Report'**
  String get rptShareSubject;

  /// Toast when exporting the PDF report fails
  ///
  /// In en, this message translates to:
  /// **'Could not create the PDF. Please try again.'**
  String get rptPdfExportFailed;

  /// ROSA sub-score status when the score is 0 (home screen and PDF)
  ///
  /// In en, this message translates to:
  /// **'Not assessed'**
  String get rptSubScoreNotAssessed;

  /// ROSA sub-score status, score 3 or more
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get rptSubScoreHighRisk;

  /// ROSA sub-score status, score 2
  ///
  /// In en, this message translates to:
  /// **'Review needed'**
  String get rptSubScoreReviewNeeded;

  /// Final ROSA score label, score 7 to 10
  ///
  /// In en, this message translates to:
  /// **'High risk — immediate action required'**
  String get rptFinalHighRisk;

  /// Final ROSA score label, score 4 to 6
  ///
  /// In en, this message translates to:
  /// **'Moderate risk — further investigation'**
  String get rptFinalModerateRisk;

  /// Final ROSA score label, score 1 to 3
  ///
  /// In en, this message translates to:
  /// **'Low risk — no immediate action needed'**
  String get rptFinalLowRisk;

  /// ROSA action level under the final score, score 7 to 10
  ///
  /// In en, this message translates to:
  /// **'Level 3 — Action required as soon as possible'**
  String get rptActionLevel3;

  /// ROSA action level under the final score, score 4 to 6
  ///
  /// In en, this message translates to:
  /// **'Level 2 — Further investigation needed'**
  String get rptActionLevel2;

  /// ROSA action level under the final score, score 1 to 3
  ///
  /// In en, this message translates to:
  /// **'Level 1 — No immediate action needed'**
  String get rptActionLevel1;

  /// ROSA sub-score category name
  ///
  /// In en, this message translates to:
  /// **'Seat Height'**
  String get rptCategorySeatHeight;

  /// ROSA sub-score category name
  ///
  /// In en, this message translates to:
  /// **'Backrest'**
  String get rptCategoryBackrest;

  /// ROSA sub-score category name
  ///
  /// In en, this message translates to:
  /// **'Armrest'**
  String get rptCategoryArmrest;

  /// ROSA sub-score category name
  ///
  /// In en, this message translates to:
  /// **'Chair'**
  String get rptCategoryChair;

  /// ROSA sub-score category name
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get rptCategoryMonitor;

  /// ROSA sub-score category name
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get rptCategoryKeyboard;

  /// ROSA sub-score category name
  ///
  /// In en, this message translates to:
  /// **'Mouse'**
  String get rptCategoryMouse;

  /// ROSA sub-score category name (phone and other peripherals)
  ///
  /// In en, this message translates to:
  /// **'Peripheral'**
  String get rptCategoryPeripheral;

  /// Supplemental CPE finding (code B_PHONE_CRADLE)
  ///
  /// In en, this message translates to:
  /// **'Cradles the phone between ear and shoulder during calls'**
  String get rptCpePhoneCradle;

  /// Supplemental CPE finding (code B_PHONE_HANDSFREE)
  ///
  /// In en, this message translates to:
  /// **'No hands-free option available for phone calls'**
  String get rptCpePhoneHandsfree;

  /// Section heading on the home screen and in the PDF
  ///
  /// In en, this message translates to:
  /// **'Supplemental CPE Findings'**
  String get rptSupplementalCpeFindings;

  /// PDF document title (file metadata)
  ///
  /// In en, this message translates to:
  /// **'Postura Ergonomic Assessment Report'**
  String get rptPdfDocumentTitle;

  /// PDF page footer
  ///
  /// In en, this message translates to:
  /// **'Postura - Ergonomic Assessment Report'**
  String get rptPdfFooter;

  /// PDF page number in the footer
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String rptPdfPageOf(int page, int total);

  /// PDF main title under the POSTURA brand
  ///
  /// In en, this message translates to:
  /// **'Ergonomic Assessment Report'**
  String get rptPdfTitle;

  /// PDF header row label
  ///
  /// In en, this message translates to:
  /// **'Assessment date'**
  String get rptPdfAssessmentDate;

  /// PDF header row label: the employee's body height
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get rptPdfHeight;

  /// Shown instead of a ROSA score when there is no valid score
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get rptNotAvailable;

  /// PDF note under the ROSA score when the ergonomist revised the answers; name is the ergonomist, score is like '5 / 10' or N/A
  ///
  /// In en, this message translates to:
  /// **'Updated by the ergonomist ({name}). Original score from the employee\'s answers: {score}'**
  String rptPdfRevisionNoteNamed(String name, String score);

  /// Same as rptPdfRevisionNoteNamed when the ergonomist's name is unknown
  ///
  /// In en, this message translates to:
  /// **'Updated by the ergonomist. Original score from the employee\'s answers: {score}'**
  String rptPdfRevisionNote(String score);

  /// PDF callout title when the chronicity (long-term pain) risk is elevated
  ///
  /// In en, this message translates to:
  /// **'Recovery Outlook: Elevated'**
  String get rptRecoveryOutlookTitle;

  /// PDF callout body when the chronicity risk is elevated
  ///
  /// In en, this message translates to:
  /// **'Your answers indicate a higher risk that the current pain could become longer-term. Early targeted support is recommended in addition to the workstation adjustments below.'**
  String get rptRecoveryOutlookBody;

  /// PDF table column header
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get rptColumnCategory;

  /// PDF table column header
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get rptColumnScore;

  /// PDF table column header
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get rptColumnStatus;

  /// PDF table column header
  ///
  /// In en, this message translates to:
  /// **'Body region'**
  String get rptColumnBodyRegion;

  /// PDF table column header
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get rptColumnRisk;

  /// PDF table column header
  ///
  /// In en, this message translates to:
  /// **'Pain level (0-10)'**
  String get rptColumnPainLevel;

  /// Body region row in the PDF 'Risk by Body Region' table
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get rptRegionShoulder;

  /// Body region row in the PDF 'Risk by Body Region' table
  ///
  /// In en, this message translates to:
  /// **'Wrist'**
  String get rptRegionWrist;

  /// PDF section heading
  ///
  /// In en, this message translates to:
  /// **'Reported Pain & Symptoms'**
  String get rptPdfReportedPainSymptoms;

  /// PDF label before the reported pain duration
  ///
  /// In en, this message translates to:
  /// **'Pain duration'**
  String get rptPdfPainDuration;

  /// PDF label before the reported symptoms
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get rptPdfSymptoms;

  /// PDF section heading (the correction / action report)
  ///
  /// In en, this message translates to:
  /// **'ROSA Posture Guidance'**
  String get rptPdfPostureGuidance;

  /// Action report tier line on the equipment screen and in the PDF; name comes from the server
  ///
  /// In en, this message translates to:
  /// **'Tier {number} - {name} | ROSA {score}/10'**
  String rptTierLine(String number, String name, String score);

  /// PDF line; driver comes from the server
  ///
  /// In en, this message translates to:
  /// **'Main risk driver: {driver}'**
  String rptPdfMainRiskDriver(String driver);

  /// PDF sub-heading
  ///
  /// In en, this message translates to:
  /// **'Priority Findings'**
  String get rptPdfPriorityFindings;

  /// PDF sub-heading
  ///
  /// In en, this message translates to:
  /// **'What You Can Do Right Now'**
  String get rptPdfWhatYouCanDoNow;

  /// PDF sub-heading
  ///
  /// In en, this message translates to:
  /// **'When Equipment Helps'**
  String get rptPdfWhenEquipmentHelps;

  /// PDF sub-heading
  ///
  /// In en, this message translates to:
  /// **'General Workstation Habits'**
  String get rptPdfGeneralWorkstationHabits;

  /// PDF section heading
  ///
  /// In en, this message translates to:
  /// **'Personalized Exercise Programme'**
  String get rptPdfExerciseProgramme;

  /// PDF callout title when exercises are stopped for clinical assessment
  ///
  /// In en, this message translates to:
  /// **'Please Check In With a Professional'**
  String get rptPdfCheckInWithProfessional;

  /// PDF callout body (fallback when the server sends no message)
  ///
  /// In en, this message translates to:
  /// **'Based on your screening answers, please consult a healthcare professional before starting exercises.'**
  String get rptPdfConsultBeforeExercises;

  /// PDF exercise programme intensity (readiness MODERATE)
  ///
  /// In en, this message translates to:
  /// **'Moderate programme'**
  String get rptPdfModerateProgramme;

  /// PDF exercise programme intensity (any other readiness)
  ///
  /// In en, this message translates to:
  /// **'Gentle programme'**
  String get rptPdfGentleProgramme;

  /// PDF callout when the exercises need CPE review
  ///
  /// In en, this message translates to:
  /// **'Based on your answers, we recommend keeping these gentle and reviewing them with your CPE or a healthcare professional. Stop immediately if any exercise increases your symptoms.'**
  String get rptPdfNeedsCpeReview;

  /// PDF exercise line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Body area: {value}'**
  String rptPdfBodyArea(String value);

  /// PDF exercise line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Muscles / body area: {value}'**
  String rptPdfMusclesBodyArea(String value);

  /// PDF exercise line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'How to do it: {value}'**
  String rptPdfHowToDoIt(String value);

  /// PDF exercise line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Why this helps: {value}'**
  String rptPdfWhyThisHelps(String value);

  /// PDF exercise line: number of sets
  ///
  /// In en, this message translates to:
  /// **'Sets: {count}'**
  String rptPdfSets(int count);

  /// PDF exercise line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Duration: {value}'**
  String rptPdfDuration(String value);

  /// PDF exercise line: the employee's pain rating for the region
  ///
  /// In en, this message translates to:
  /// **'Pain level (VAS): {value} / 10'**
  String rptPdfPainLevelVas(String value);

  /// PDF exercise line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'When not to use / when to stop: {value}'**
  String rptPdfWhenNotToUse(String value);

  /// PDF exercise line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'When to stop: {value}'**
  String rptPdfWhenToStop(String value);

  /// PDF equipment card line; value is a list from the server
  ///
  /// In en, this message translates to:
  /// **'Related findings: {value}'**
  String rptPdfRelatedFindings(String value);

  /// PDF equipment card line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Why this appears: {value}'**
  String rptPdfWhyThisAppears(String value);

  /// PDF equipment card line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Target: {value}'**
  String rptPdfTarget(String value);

  /// PDF equipment card line; value is a list from the server
  ///
  /// In en, this message translates to:
  /// **'Required features: {value}'**
  String rptPdfRequiredFeatures(String value);

  /// PDF equipment card line; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Next step: {value}'**
  String rptPdfNextStep(String value);

  /// PDF line for older equipment lists; value comes from the server
  ///
  /// In en, this message translates to:
  /// **'Priority: {value}'**
  String rptPdfPriority(String value);

  /// PDF line for older equipment lists; value is a status code from the server
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String rptPdfStatus(String value);

  /// Equipment card title (on-device engine for scans before v1.3)
  ///
  /// In en, this message translates to:
  /// **'Adjustable monitor riser'**
  String get rptEquipMonitorRiserTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Height-adjustable stand (8–12 cm) to position monitor at eye level.'**
  String get rptEquipMonitorRiserDescription;

  /// Equipment card title (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Adjustable footrest'**
  String get rptEquipFootrestTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Angled footrest with height adjustment (10–15 cm) for stable foot support.'**
  String get rptEquipFootrestDescription;

  /// Equipment card title (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Lumbar support cushion'**
  String get rptEquipLumbarCushionTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Memory-foam lumbar roll to support the lower back in the chair.'**
  String get rptEquipLumbarCushionDescription;

  /// Equipment card title (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Wrist rest'**
  String get rptEquipWristRestTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Soft wrist rest to support neutral wrist posture while typing.'**
  String get rptEquipWristRestDescription;

  /// Equipment card title (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Keyboard tray'**
  String get rptEquipKeyboardTrayTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Under-desk keyboard tray to set keyboard height at elbow level.'**
  String get rptEquipKeyboardTrayDescription;

  /// Equipment card title (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Ergonomic mouse'**
  String get rptEquipErgonomicMouseTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Alternative mouse design to reduce lateral wrist and shoulder loading.'**
  String get rptEquipErgonomicMouseDescription;

  /// Equipment card title (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Armrest pads/risers'**
  String get rptEquipArmrestPadsTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Adjustable armrest pads (+3 cm or more) to support forearms at elbow height.'**
  String get rptEquipArmrestPadsDescription;

  /// Equipment card title for standing desks (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Anti-fatigue mat'**
  String get rptEquipAntiFatigueMatTitle;

  /// Equipment card description (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Cushioned mat to reduce leg and lower-back fatigue during prolonged standing.'**
  String get rptEquipAntiFatigueMatDescription;

  /// Equipment card source line (shown after 'Source:')
  ///
  /// In en, this message translates to:
  /// **'ISO 9241-5:2024; ROSA monitor section.'**
  String get rptEquipSourceIsoMonitor;

  /// Equipment card source line
  ///
  /// In en, this message translates to:
  /// **'ISO 9241-5:2024; ROSA chair section.'**
  String get rptEquipSourceIsoChair;

  /// Equipment card source line (keep the citation as is)
  ///
  /// In en, this message translates to:
  /// **'Rempel et al. 2006; ROSA keyboard section.'**
  String get rptEquipSourceRempelKeyboard;

  /// Equipment card source line
  ///
  /// In en, this message translates to:
  /// **'ISO 9241-5:2024; ROSA keyboard section.'**
  String get rptEquipSourceIsoKeyboard;

  /// Equipment card source line (keep the citation as is)
  ///
  /// In en, this message translates to:
  /// **'Van Eerd et al. 2016; ROSA mouse section.'**
  String get rptEquipSourceVanEerdMouse;

  /// Equipment card source line (keep the citation as is)
  ///
  /// In en, this message translates to:
  /// **'Van Eerd et al. 2016; ROSA armrest section.'**
  String get rptEquipSourceVanEerdArmrest;

  /// Equipment card source line
  ///
  /// In en, this message translates to:
  /// **'ISO 9241-5:2024; standing workstation section.'**
  String get rptEquipSourceIsoStanding;

  /// Badge on an equipment card with the ROSA sub-score
  ///
  /// In en, this message translates to:
  /// **'Monitor risk: {score}'**
  String rptRiskBadgeMonitor(int score);

  /// Badge on an equipment card with the ROSA sub-score
  ///
  /// In en, this message translates to:
  /// **'Chair risk: {score}'**
  String rptRiskBadgeChair(int score);

  /// Badge on an equipment card with the ROSA sub-score
  ///
  /// In en, this message translates to:
  /// **'Keyboard risk: {score}'**
  String rptRiskBadgeKeyboard(int score);

  /// Badge on an equipment card with the ROSA sub-score
  ///
  /// In en, this message translates to:
  /// **'Mouse risk: {score}'**
  String rptRiskBadgeMouse(int score);

  /// Badge on an equipment card with the ROSA sub-score
  ///
  /// In en, this message translates to:
  /// **'Armrest risk: {score}'**
  String rptRiskBadgeArmrest(int score);

  /// Equipment tier banner message, tier RED (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Immediate ergonomic action required for this workstation.'**
  String get rptEquipTierMessageRed;

  /// Equipment tier banner message, tier ORANGE
  ///
  /// In en, this message translates to:
  /// **'Plan and implement these equipment changes to reduce ergonomic risk.'**
  String get rptEquipTierMessageOrange;

  /// Equipment tier banner message, tier GREEN
  ///
  /// In en, this message translates to:
  /// **'No urgent actions; maintain current setup and continue monitoring.'**
  String get rptEquipTierMessageGreen;

  /// Equipment tier banner message, tier YELLOW
  ///
  /// In en, this message translates to:
  /// **'Symptoms reported; consider equipment changes and follow-up review.'**
  String get rptEquipTierMessageYellow;

  /// Equipment tier badge (upper case)
  ///
  /// In en, this message translates to:
  /// **'RED'**
  String get rptTierRed;

  /// Equipment tier badge (upper case)
  ///
  /// In en, this message translates to:
  /// **'ORANGE'**
  String get rptTierOrange;

  /// Equipment tier badge (upper case)
  ///
  /// In en, this message translates to:
  /// **'GREEN'**
  String get rptTierGreen;

  /// Equipment tier badge (upper case)
  ///
  /// In en, this message translates to:
  /// **'YELLOW'**
  String get rptTierYellow;

  /// Equipment card urgency badge, level 3
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get rptUrgencyUrgent;

  /// Equipment card urgency badge, level 2
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get rptUrgencyRecommended;

  /// Equipment card urgency badge, level 1
  ///
  /// In en, this message translates to:
  /// **'Preventive'**
  String get rptUrgencyPreventive;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Tingling may indicate nerve compression — consult a healthcare provider if symptoms persist.'**
  String get rptEquipNoteTingling;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Fatigue reported — high desk exposure amplifies strain risk.'**
  String get rptEquipNoteFatigue;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Use a laptop stand + external keyboard.'**
  String get rptEquipNoteLaptopStand;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Ensure primary screen is centred; secondary at same height.'**
  String get rptEquipNoteDualScreen;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Neck rotation risk detected — consider single primary screen.'**
  String get rptEquipNoteNeckRotation;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Consider adding an external mouse to reduce wrist load.'**
  String get rptEquipNoteExternalMouse;

  /// Equipment card note for hybrid work zones (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Recommendations apply to your seated setup.'**
  String get rptEquipNoteHybrid;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Take breaks every 30–60 min to allow posture variation.'**
  String get rptEquipNoteBreaksRarely;

  /// Equipment card note (on-device engine)
  ///
  /// In en, this message translates to:
  /// **'Increase break frequency to reduce sustained load.'**
  String get rptEquipNoteBreaksEvery3h;

  /// Equipment card source when the server gives none (shown after 'Source:')
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get rptUnknown;

  /// Equipment request status chip (code ACTIONED)
  ///
  /// In en, this message translates to:
  /// **'Actioned'**
  String get rptStatusActioned;

  /// Amber banner on an equipment card when pain is long-term
  ///
  /// In en, this message translates to:
  /// **'Long-term condition — consistent use recommended'**
  String get rptLongTermCondition;

  /// Section heading on the v1.3 equipment card
  ///
  /// In en, this message translates to:
  /// **'Related findings'**
  String get rptRelatedFindings;

  /// Section heading on the v1.3 equipment card
  ///
  /// In en, this message translates to:
  /// **'Why this appears'**
  String get rptWhyThisAppears;

  /// Section heading on the v1.3 equipment card
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get rptTarget;

  /// Section heading on the v1.3 equipment card
  ///
  /// In en, this message translates to:
  /// **'Required features'**
  String get rptRequiredFeatures;

  /// Section heading on the v1.3 equipment card
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get rptNextStep;

  /// Ergonomist review, approvals checklist item
  ///
  /// In en, this message translates to:
  /// **'Posture landmarks are valid and accurate'**
  String get rvwApprovalLandmarksVerified;

  /// Ergonomist review, approvals checklist item
  ///
  /// In en, this message translates to:
  /// **'Workstation equipment is correctly identified'**
  String get rvwApprovalWorkstationVerified;

  /// Ergonomist review, approvals checklist item
  ///
  /// In en, this message translates to:
  /// **'ROSA score calculation is verified'**
  String get rvwApprovalRosaVerified;

  /// Ergonomist review, approvals checklist item
  ///
  /// In en, this message translates to:
  /// **'Recommendations are professionally appropriate'**
  String get rvwApprovalRecommendationsVerified;

  /// Review decision label (value FOLLOW_UP_REQUIRED)
  ///
  /// In en, this message translates to:
  /// **'Follow Up Required'**
  String get rvwFollowUpRequired;

  /// Review decision label (value NEED_CHANGE)
  ///
  /// In en, this message translates to:
  /// **'Need Changes'**
  String get rvwNeedChanges;

  /// Ergonomist review: employee's body height section title
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get rvwHeight;

  /// Ergonomist review: employee height was not given
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get rvwNotProvided;

  /// ROSA sub-score status chip, score 0
  ///
  /// In en, this message translates to:
  /// **'Not assessed'**
  String get rvwNotAssessed;

  /// ROSA sub-score status chip, score 3+
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get rvwHighRisk;

  /// ROSA sub-score status chip, score 2
  ///
  /// In en, this message translates to:
  /// **'Review needed'**
  String get rvwReviewNeeded;

  /// Final ROSA score band, 7-10
  ///
  /// In en, this message translates to:
  /// **'High risk — immediate action required'**
  String get rvwFinalHighRisk;

  /// Final ROSA score band, 4-6
  ///
  /// In en, this message translates to:
  /// **'Moderate risk — further investigation'**
  String get rvwFinalModerateRisk;

  /// Final ROSA score band, 1-3
  ///
  /// In en, this message translates to:
  /// **'Low risk — no immediate action needed'**
  String get rvwFinalLowRisk;

  /// ROSA action level, final score 7-10
  ///
  /// In en, this message translates to:
  /// **'Level 3 — Action required as soon as possible'**
  String get rvwActionLevel3;

  /// ROSA action level, final score 4-6
  ///
  /// In en, this message translates to:
  /// **'Level 2 — Further investigation needed'**
  String get rvwActionLevel2;

  /// ROSA action level, final score 1-3
  ///
  /// In en, this message translates to:
  /// **'Level 1 — No immediate action needed'**
  String get rvwActionLevel1;

  /// Ergonomist review: section title for the action report
  ///
  /// In en, this message translates to:
  /// **'Action Report v1.3'**
  String get rvwActionReportTitle;

  /// Action report summary line; tierName and mainRiskDriver come from the server untranslated
  ///
  /// In en, this message translates to:
  /// **'Tier {tierNumber} - {tierName} | ROSA {rosaScore}/10 | Main risk driver: {mainRiskDriver}'**
  String rvwActionReportSummary(int tierNumber, String tierName, int rosaScore, String mainRiskDriver);

  /// Action report subsection title
  ///
  /// In en, this message translates to:
  /// **'Priority Findings'**
  String get rvwPriorityFindings;

  /// Action report subsection title
  ///
  /// In en, this message translates to:
  /// **'Supplemental CPE Findings'**
  String get rvwSupplementalCpeFindings;

  /// Ergonomist home header greeting
  ///
  /// In en, this message translates to:
  /// **'Hi {name}'**
  String rvwGreetingName(String name);

  /// Caption under the score on an assessment card in the ergonomist's list (upper case)
  ///
  /// In en, this message translates to:
  /// **'ROSA SCORE'**
  String get rvwRosaScoreCaps;

  /// Photo caption on the ergonomist review
  ///
  /// In en, this message translates to:
  /// **'Side view {number}'**
  String rvwSideViewNumber(int number);

  /// Photo caption on the ergonomist review
  ///
  /// In en, this message translates to:
  /// **'Front view'**
  String get rvwFrontView;

  /// Measured angle chip label, front photo
  ///
  /// In en, this message translates to:
  /// **'Elbow abduction'**
  String get rvwElbowAbduction;

  /// Angle chip value when the angle could not be measured
  ///
  /// In en, this message translates to:
  /// **'Not measured'**
  String get rvwNotMeasured;

  /// Measured angle chip label, side photo
  ///
  /// In en, this message translates to:
  /// **'Knee'**
  String get rvwMetricKnee;

  /// Measured angle chip label, side photo
  ///
  /// In en, this message translates to:
  /// **'Trunk'**
  String get rvwMetricTrunk;

  /// Measured angle chip label, side photo
  ///
  /// In en, this message translates to:
  /// **'Elbow'**
  String get rvwMetricElbow;

  /// Chip label, side photo: neck posture classification
  ///
  /// In en, this message translates to:
  /// **'Neck state'**
  String get rvwMetricNeckState;

  /// Chip label, side photo: lower-body detection confidence
  ///
  /// In en, this message translates to:
  /// **'Lower body'**
  String get rvwMetricLowerBody;

  /// Chip label, side photo: whether a monitor was found
  ///
  /// In en, this message translates to:
  /// **'Monitor detected'**
  String get rvwMetricMonitorDetected;

  /// Chip label, side photo: top of monitor relative to eye level
  ///
  /// In en, this message translates to:
  /// **'Monitor top vs eye level'**
  String get rvwMetricMonitorTopVsEyeLevel;

  /// Generic answer value
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get rvwNo;

  /// Top of monitor is below eye level (value 'below')
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get rvwMonitorBelow;

  /// Top of monitor is at eye level (value 'at')
  ///
  /// In en, this message translates to:
  /// **'At eye level'**
  String get rvwMonitorAtEyeLevel;

  /// Top of monitor is above eye level (value 'above')
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get rvwMonitorAbove;

  /// Chronicity risk level 'Low' (risk of long-term problems), shown after 'Recovery outlook:'
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get rvwChronicityLow;

  /// Chronicity risk level 'Elevated' (risk of long-term problems), shown after 'Recovery outlook:'
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get rvwChronicityElevated;

  /// Ergonomist review: health screening section title
  ///
  /// In en, this message translates to:
  /// **'Health Screening'**
  String get rvwHealthScreening;

  /// Health screening privacy note
  ///
  /// In en, this message translates to:
  /// **'Visible to ergonomists only. Not shared with the company.'**
  String get rvwHealthScreeningPrivacy;

  /// Health screening group title
  ///
  /// In en, this message translates to:
  /// **'Safety Questions (Red Flags)'**
  String get rvwSafetyQuestionsRedFlags;

  /// Red-flag screening result, positive
  ///
  /// In en, this message translates to:
  /// **'Positive: exercises withheld, refer to a healthcare professional'**
  String get rvwRedFlagPositive;

  /// Red-flag screening result, negative
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get rvwRedFlagNegative;

  /// Work ability group status; level is rvwChronicityLow / rvwChronicityElevated (or the raw server value)
  ///
  /// In en, this message translates to:
  /// **'Recovery outlook: {level}'**
  String rvwRecoveryOutlookStatus(String level);
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
