import 'package:flutter/material.dart';
import 'package:shlih_kitchen/screens/signin.dart';
import 'package:shlih_kitchen/screens/splashscreen1.dart';
import 'package:shlih_kitchen/screens/splashscreen2.dart';
import 'package:shlih_kitchen/screens/splashscreen3.dart';

class SplashScreenManager extends StatefulWidget {
  const SplashScreenManager({super.key});

  @override
  State<SplashScreenManager> createState() => _SplashScreenManagerState();
}

class _SplashScreenManagerState extends State<SplashScreenManager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (_currentPage < 2) {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        } else {
          _navigateToMainScreen();
        }
      }
    });
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    _currentPage = index;
                  });
                }
              },
              children: [
                SplashScreen1(
                  pageController: _pageController,
                ),
                SplashScreen2(
                  pageController: _pageController,
                ),
                SplashScreen3(
                  pageController: _pageController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
