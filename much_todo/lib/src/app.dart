import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:much_todo/src/home/home.dart';
import 'package:much_todo/src/sign_in/sign_in_screen.dart';
import 'package:much_todo/src/sign_in/unverified_screen.dart';
import 'package:much_todo/src/theme/themes.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/settings_provider.dart';

class MyApp extends StatelessWidget {
  final SettingsProvider settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    String? initialRoute;
    if (FirebaseAuth.instance.currentUser == null) {
      initialRoute = SignInScreen.routeName;
    } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      initialRoute = UnverifiedScreen.routeName;
    } else {
      initialRoute = Home.routeName;
    }

    return MaterialApp(
      restorationScopeId: 'app',
      initialRoute: initialRoute,

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
      onGenerateInitialRoutes: (initialRoute) {
        if (initialRoute == UnverifiedScreen.routeName) {
          return [MaterialPageRoute(builder: (ctx) => unverifiedWidget(context))];
        } else if (initialRoute == SignInScreen.routeName) {
          return [MaterialPageRoute(builder: (ctx) => signInWidget(context))];
        } else {
          return [MaterialPageRoute(builder: (ctx) => homeWidget(context))];
        }
      },
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case Home.routeName:
                return homeWidget(context);
              case SignInScreen.routeName:
                return signInWidget(context);
              case UnverifiedScreen.routeName:
                return unverifiedWidget(context);
              default:
                return homeWidget(context);
            }
          },
        );
      },
    );
  }

  Widget homeWidget(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: context.watch<SettingsProvider>().themeMode == ThemeMode.dark
            ? darkColorScheme.background
            : lightColorScheme.background,
        systemNavigationBarIconBrightness:
            context.watch<SettingsProvider>().themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
      ),
      child: Home(controller: settingsController),
    );
  }

  Widget signInWidget(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SignInScreen(),
    );
  }

  Widget unverifiedWidget(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: UnverifiedScreen(),
    );
  }
}
