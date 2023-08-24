import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

  /*
  	Load the user's preferred theme while the splash screen is displayed.
  	This prevents a sudden theme change when the app is first displayed.
   */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
