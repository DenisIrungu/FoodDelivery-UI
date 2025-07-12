import 'package:flutter/material.dart';
import 'package:shlih_kitchen/appView.dart';

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return AppView(navigatorKey: navigatorKey);
  }
}
