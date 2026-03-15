import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posture_detector_app/data/services/db/sqlite_service.dart';
import 'package:posture_detector_app/core/bindings/app_binding.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/routes.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppHelper.init();
  await Sqlite.instance.init();

  final savedLang = await AppHelper.instance.getLanguage();

  runApp(MyApp(savedLocale: savedLang != null ? Locale(savedLang) : null));
}

//
class MyApp extends StatelessWidget {
  final Locale? savedLocale;

  const MyApp({super.key, this.savedLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Posture detector app',
        theme: ThemeData(
          fontFamily: GoogleFonts.inter().fontFamily,
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        themeMode: ThemeMode.light,
        initialRoute: AppRoute.splashScreen,
        getPages: AppRoute.routes,
        initialBinding: AppBindings(),
        scaffoldMessengerKey: scaffoldMessengerKey,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('es'),
          Locale('de'),
          Locale('nl'),
        ],
        locale: savedLocale ?? Get.deviceLocale,
        fallbackLocale: Locale('en'),
      ),
    );
  }
}
