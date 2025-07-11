import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shlih_kitchen/screens/home.dart';
import 'package:shlih_kitchen/screens/mainscreen.dart';
import 'package:shlih_kitchen/services/auth/signinorsignup.dart';
import 'package:shlih_kitchen/services/auth_services.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    print('AuthGate build method called!');
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: AuthServices().authStateChanges,
        builder: (context, snapshot) {
          // Debug prints
          print('AuthGate - ConnectionState: ${snapshot.connectionState}');
          print('AuthGate - HasData: ${snapshot.hasData}');
          print('AuthGate - User: ${snapshot.data?.email}');
          print('AuthGate - Error: ${snapshot.error}');

          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            print(
                'Auth state: ${snapshot.connectionState}, User: ${snapshot.data?.email}');
            if (user == null) {
              print('AuthGate - Showing SignInorSignUp');
              return const SignInorSignUp();
            }
            print('AuthGate - Showing HomePage');
            // Navigate to HomePage for all authenticated users
            return const MainScreen();
          }
          print('AuthGate - Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
