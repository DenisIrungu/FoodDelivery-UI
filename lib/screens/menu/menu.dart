import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/components/mygrid.dart';
import 'package:shlih_kitchen/components/mytextfield.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:shlih_kitchen/models/foods.dart';
import 'package:shlih_kitchen/screens/menu/cart.dart';

import '../foodpage.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  final _searchMenu = TextEditingController();
  late TabController _tabController;
  String _searchQuery = ''; // To store the search query

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);
    // Listen to search field changes
    _searchMenu.addListener(() {
      setState(() {
        _searchQuery = _searchMenu.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchMenu.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> _buildTabs() {
    return FoodCategory.values.map((category) {
      final label = category.toString().split('.').last;
      final spaced =
          label.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}').trim();
      return Tab(text: spaced);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Access the Restaurant instance using Provider
    final restaurant = Provider.of<Restaurant>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Menu',
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
            color: Theme.of(context).colorScheme.tertiary,
            iconSize: 30,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Cart()));
            },
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).colorScheme.tertiary,
            iconSize: 30,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Food',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Special for you',
                style: TextStyle(
                  color: const Color(0xFF0F2A12),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _searchMenu,
                hintText: 'Search your Menu',
                obscureText: false,
                prefixIcon: const Icon(Icons.search, size: 24),
              ),
              const SizedBox(height: 20),
              PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Material(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.tertiary,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      color: const Color(0xFF0F2A12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tabs: _buildTabs(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: FoodCategory.values.map((category) {
                    // Filter items by category and search query
                    final items = category == FoodCategory.All
                        ? restaurant.menu
                        : restaurant.menu
                            .where((item) => item.category == category)
                            .toList();
                    final filteredItems = items
                        .where((item) =>
                            item.title.toLowerCase().contains(_searchQuery))
                        .toList();

                    return filteredItems.isEmpty
                        ? const Center(child: Text('No items found'))
                        : GridView.builder(
                            itemCount: filteredItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return MyGrid(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FoodPage(food: item))),
                                imagePath: item.imagePath,
                                title: item.title,
                                price: '\$${item.price.toStringAsFixed(2)}',
                              );
                            },
                          );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
