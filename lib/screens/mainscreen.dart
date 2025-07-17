import 'package:flutter/material.dart';
import 'package:shlih_kitchen/screens/home.dart';
import 'package:shlih_kitchen/screens/menu/menu.dart';
import 'package:shlih_kitchen/screens/menu/cart.dart';
import 'package:shlih_kitchen/screens/menu/profile.dart';
import '../components/custombottonnavbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    Menu(),
    Cart(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
