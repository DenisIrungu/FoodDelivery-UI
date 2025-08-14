import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/app.dart';
import 'package:shlih_kitchen/firebase_options.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:shlih_kitchen/screens/payments/mpesa/mpesa_provider.dart';
import 'package:shlih_kitchen/screens/payments/redeem/redemptionprovider.dart';
import 'package:shlih_kitchen/services/database/firestore.dart';
import 'package:shlih_kitchen/themes/theme_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // Theme provider for app theming
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // Restaurant provider for menu and cart management
        ChangeNotifierProvider(create: (context) => Restaurant()),

        // Firestore services for database operations (orders, etc.)
        Provider<FirestoreServices>(create: (context) => FirestoreServices()),

        // M-Pesa provider for payment processing
        ChangeNotifierProvider(create: (context) => MpesaProvider()),

        // Redemption provider for points redemption
        ChangeNotifierProvider(create: (context) => RedemptionProvider()),
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}
