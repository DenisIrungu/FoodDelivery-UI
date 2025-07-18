import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shlih_kitchen/services/auth/signinorsignup.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/services/auth_gate.dart';


class SplashScreen3 extends StatelessWidget {
  final PageController pageController;
  const SplashScreen3({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    //final double circleRadius = 140;
    final double floatingImageSize = 45;
    final double borderWidth = 10;

    // Angles: Top (12), Left (9), Right (3), Bottom (6)
    final List<double> baseAngles = [
      -pi / 2, // Top-center
      pi, // Left-center
      0, // Right-center
      pi / 2, // Bottom-center
    ];

    final List<String> floatingImages = [
      'assets/favfood1.jpg',
      'assets/favfood2.jpg',
      'assets/favfood3.jpg',
      'assets/favfood4.jpg',
    ];

    // Calculate the radius to position images so they sit on the border exactly like the top one
    final double containerRadius = 140; // Half of 280px container
    final double positionRadius = containerRadius +
        (borderWidth / 2) -
        (floatingImageSize / 6); // Fine-tuned to match top image

    // Calculate required space for the Stack to prevent clipping
    final double stackSize =
        (containerRadius + borderWidth + floatingImageSize) * 2;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/log1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'SHLIH Kitchen',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                flex: 3,
                child: Center(
                  child: SizedBox(
                    width: stackSize,
                    height: stackSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Main circular background with bowl
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white,
                              width: borderWidth,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/delivery2.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Floating images positioned on the white border
                        for (int i = 0; i < baseAngles.length; i++)
                          Positioned(
                            left: (stackSize / 2) +
                                cos(baseAngles[i]) *
                                    (i == 1
                                        ? containerRadius + borderWidth
                                        : (i == 2
                                            ? positionRadius - 10
                                            : positionRadius)) -
                                floatingImageSize / 2,
                            top: (stackSize / 2) +
                                sin(baseAngles[i]) *
                                    (i == 0
                                        ? containerRadius + borderWidth + 10
                                        : (i == 3
                                            ? positionRadius - 25
                                            : positionRadius)) -
                                floatingImageSize / 2,
                            child: Container(
                              width: floatingImageSize,
                              height: floatingImageSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  floatingImages[i],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    'Get deliveries at your door step',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 37,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'From our bustling kitchen straight to your doorstep in no time at all!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: MyButton(
                      text: 'Get Started',
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthGate()),
                        );
                      },
                      color: const Color(0xFF0F2A12),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyButton(
                    text: 'Sign In',
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignInorSignUp()),
                      );
                    },
                    color: Colors.grey.shade500,
                    foregroundColor: Color(0xFF0F2A12),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
