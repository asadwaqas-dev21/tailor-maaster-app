import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:tailor_app/l10n/gen/app_localizations.dart";
import "package:tailor_app/app/routes.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_theme.dart";
import "package:tailor_app/app/theme/app_typography.dart";
import "package:tailor_app/data/repositories/customer_repository_impl.dart";
import "package:tailor_app/data/repositories/measurement_repository_impl.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/presentation/blocs/customer/customer_bloc.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_bloc.dart";
import "package:tailor_app/presentation/blocs/measurement/measurement_bloc.dart";
import "package:tailor_app/presentation/blocs/order/order_bloc.dart";
import "package:tailor_app/presentation/blocs/settings/settings_bloc.dart";
import "package:tailor_app/presentation/blocs/settings/settings_event.dart";
import "package:tailor_app/presentation/blocs/settings/settings_state.dart";
import "package:tailor_app/data/repositories/staff_repository_impl.dart";
import "package:tailor_app/presentation/blocs/staff/staff_bloc.dart";

class TailorProApp extends StatelessWidget {
  const TailorProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final customerRepo = CustomerRepositoryImpl();
    final orderRepo = OrderRepositoryImpl();
    final measurementRepo = MeasurementRepositoryImpl();
    final staffRepo = StaffRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc()..add(const LoadSettings())),
        BlocProvider(create: (_) => CustomerBloc(repository: customerRepo)),
        BlocProvider(create: (_) => OrderBloc(repository: orderRepo)),
        BlocProvider(
          create: (_) => MeasurementBloc(repository: measurementRepo),
        ),
        BlocProvider(create: (_) => StaffBloc(repository: staffRepo)),
        BlocProvider(
          create: (_) => DashboardBloc(
            orderRepository: orderRepo,
            customerRepository: customerRepo,
          ),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final isUrdu = settingsState.locale.languageCode == "ur";

          // Choose text theme based on locale
          ThemeData lightTheme = AppTheme.light;
          ThemeData darkTheme = AppTheme.dark;

          if (isUrdu) {
            lightTheme = lightTheme.copyWith(
              textTheme: AppTypography.urduTextTheme.apply(
                bodyColor: AppColors.ink,
                displayColor: AppColors.ink,
              ),
              appBarTheme: lightTheme.appBarTheme.copyWith(
                titleTextStyle: AppTypography.urdu(
                  size: 18,
                  weight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            );
            darkTheme = darkTheme.copyWith(
              textTheme: AppTypography.urduTextTheme.apply(
                bodyColor: AppColors.darkTextPrimary,
                displayColor: AppColors.darkTextPrimary,
              ),
              appBarTheme: darkTheme.appBarTheme.copyWith(
                titleTextStyle: AppTypography.urdu(
                  size: 18,
                  weight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            );
          }

          return MaterialApp(
            title: "Darzi",
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settingsState.themeMode,
            locale: settingsState.locale,
            supportedLocales: const [Locale("en"), Locale("ur")],
            localeResolutionCallback: (locale, supported) {
              if (locale == null) return const Locale("en");
              for (final supportedLocale in supported) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale("en");
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final dark =
                  settingsState.themeMode == ThemeMode.dark ||
                  (settingsState.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: dark
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: dark
                      ? Brightness.dark
                      : Brightness.light,
                ),
              );
              // Force RTL for Urdu even if a nested route forgets localizations.
              return Directionality(
                textDirection:
                    isUrdu ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
