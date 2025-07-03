import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/app.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:shlih_kitchen/themes/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => Restaurant()),
      ],
      child: const MyApp(),
    ),
  );
}