import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelcompanionfinder/bottom_bar.dart';
import 'package:travelcompanionfinder/home_screen.dart';
import 'register_login_screen.dart';

import 'app_theme.dart';
import 'navigation_home_screen.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureAmplify();

  final isSignedIn = await Amplify.Auth.fetchAuthSession().then((session) => session.isSignedIn);

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(MyApp(isSignedIn: isSignedIn)));
}

Future<void> _configureAmplify() async {
  final authPlugin = AmplifyAuthCognito();
  debugPrint('Adding Auth Plugin...');
  Amplify.addPlugin(authPlugin);

  try {
    await Amplify.configure(amplifyconfig);
    debugPrint('Amplify configured successfully');
  } on AmplifyAlreadyConfiguredException {
    debugPrint('Amplify already configured');
  } catch (e) {
    debugPrint('Failed to configure Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;
  const MyApp({required this.isSignedIn, super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid && !kIsWeb ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'Flutter UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: Theme.of(context).platform,   //TargetPlatform.iOS,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: isSignedIn ? const NavigationHomeScreen() : const RegisterLoginScreen(),
    );
  }
}
