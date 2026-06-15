import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:tailor_app/l10n/gen/app_localizations.dart";
import "package:tailor_app/app/routes.dart";
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
        BlocProvider(
          create: (_) => SettingsBloc()..add(const LoadSettings()),
        ),
        BlocProvider(
          create: (_) => CustomerBloc(repository: customerRepo),
        ),
        BlocProvider(
          create: (_) => OrderBloc(repository: orderRepo),
        ),
        BlocProvider(
          create: (_) => MeasurementBloc(repository: measurementRepo),
        ),
        BlocProvider(
          create: (_) => StaffBloc(repository: staffRepo),
        ),
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
              textTheme: AppTypography.urduTextTheme,
            );
            darkTheme = darkTheme.copyWith(
              textTheme: AppTypography.urduTextTheme,
            );
          }

          return MaterialApp(
            title: "TailorPro",
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settingsState.themeMode,
            locale: settingsState.locale,
            supportedLocales: const [
              Locale("en"),
              Locale("ur"),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
