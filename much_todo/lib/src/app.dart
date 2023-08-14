import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:much_todo/src/home/home.dart';
import 'package:much_todo/src/theme/themes.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'settings/settings.dart';

class MyApp extends StatelessWidget {
  final SettingsProvider settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',

      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],

      // Use AppLocalizations to configure the correct application title
      // depending on the user's locale.
      //
      // The appTitle is defined in .arb files found in the localization
      // directory.
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: darkColorScheme,
      ),
      themeMode: context.watch<SettingsProvider>().themeMode,

      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case Settings.routeName:
                return Settings(
                  controller: settingsController,
                );
              default:
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
                    systemNavigationBarIconBrightness: context.watch<SettingsProvider>().themeMode == ThemeMode.dark
                        ? Brightness.light
                        : Brightness.dark,
                  ),
                  child: Home(controller: settingsController),
                );
            }
          },
        );
      },
    );
  }
}
