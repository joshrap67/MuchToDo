import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/providers/settings_provider.dart';
import 'src/services/settings_service.dart';

void main() async {
  final settingsProvider = SettingsProvider(SettingsService());
  // todo need to set permissions in manifest

  /*
  	Load the user's preferred theme while the splash screen is displayed.
  	This prevents a sudden theme change when the app is first displayed.
   */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // todo uncomment when prod ready
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  await settingsProvider.loadSettings();

  runApp(MultiProvider(
    providers: [
      ListenableProvider<UserProvider>(create: (_) => UserProvider()),
      ListenableProvider<RoomsProvider>(create: (_) => RoomsProvider()),
      ListenableProvider<TasksProvider>(create: (_) => TasksProvider()),
      ListenableProvider<SettingsProvider>(create: (_) => settingsProvider),
    ],
    child: MyApp(settingsController: settingsProvider),
  ));
}
