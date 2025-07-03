import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/mydrawertile.dart';
import 'package:shlih_kitchen/screens/drawer/settings.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.25,
              width: MediaQuery.of(context).size.width * 0.25,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/log1.png')),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
              thickness: 2,
            ),
          ),
          MyDrawerTile(
              text: 'H O M E',
              icon: Icons.home,
              onTap: () {
                Navigator.pop(context);
              }),
          MyDrawerTile(
              text: 'S E T T I N G S',
              icon: Icons.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              }),
          const Spacer(),
          MyDrawerTile(text: 'L O G O U T', icon: Icons.logout, onTap: () {}),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
