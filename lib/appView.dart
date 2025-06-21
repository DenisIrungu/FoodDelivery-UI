import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/splashmanagement.dart';
import 'package:shlih_kitchen/screens/splashscreen1.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S H L I H  K I T C H E N',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.light(
              surface: Colors.white, onSurface: Color(0xFF0F2A12))),
      home: SplashManager(),
    );
  }
}
