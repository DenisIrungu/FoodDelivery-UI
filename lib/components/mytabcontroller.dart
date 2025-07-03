import 'package:flutter/material.dart';

class MyTabController extends StatelessWidget {
  final TabController tabController;

  const MyTabController({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide.none), // Explicitly remove bottom border
        ),
        child: TabBar(
            controller: tabController,
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            indicator: null, // Remove any indicator
            labelColor: Colors.black, // Adjust as needed
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Featured'),
              Tab(text: 'Fast Food'),
              Tab(text: 'Soup'),
              Tab(text: 'Salad'),
              Tab(text: 'Top of the week'),
            ]),
      ),
    );
  }
}
