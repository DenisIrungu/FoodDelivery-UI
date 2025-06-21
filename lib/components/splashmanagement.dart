import 'package:flutter/material.dart';
import 'package:shlih_kitchen/screens/splashscreen1.dart';
import 'package:shlih_kitchen/screens/splashscreen2.dart';
import 'package:shlih_kitchen/screens/splashscreen3.dart';

class SplashManager extends StatefulWidget {
  const SplashManager({super.key});

  @override
  State<SplashManager> createState() => _SplashManagerState();
}

class _SplashManagerState extends State<SplashManager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: const [
                SplashScreen1(),
                SplashScreen2(),
                SplashScreen3(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SHLIH Kitchen')),
      body: const Center(child: Text('Welcome to SHLIH Kitchen!')),
    );
  }
}
