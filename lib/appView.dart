import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/components/splashmanagement.dart';
import 'package:shlih_kitchen/screens/congrats.dart';
import 'package:shlih_kitchen/screens/forgotpassword.dart';
import 'package:shlih_kitchen/screens/mainscreen.dart';
import 'package:shlih_kitchen/screens/menu/all.dart';
import 'package:shlih_kitchen/auth/signin.dart';
import 'package:shlih_kitchen/auth/signup.dart';
import 'package:shlih_kitchen/themes/theme_provider.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S H L I H  K I T C H E N',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: SplashScreenManager(),
      routes: {
        '/splash': (context) => const SplashScreenManager(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/forgot': (context) => const ForgotPassword(),
        '/congrats': (context) => const Congrats(),
        '/home': (context) => const MainScreen(),
        '/all': (context) => const AllMenu()
      },
    );
  }
}
