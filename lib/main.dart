import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posture_detector_app/services/db/sqlite_service.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/provider/locale_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppHelper.init();
  await Sqlite.instance.init();

  final savedLang = await AppHelper.instance.getLanguage();
  final savedLocale = savedLang != null ? Locale(savedLang) : null;

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(
          (ref) => savedLocale ?? const Locale('en'),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: Size(375, 812),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Postura',
        theme: ThemeData(
          fontFamily: GoogleFonts.inter().fontFamily,
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        themeMode: ThemeMode.light,
        routerConfig: AppRoute.allRoutes,
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
        locale: locale,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale?.languageCode) return supported;
          }
          return const Locale('en');
        },
      ),
    );
  }
}
