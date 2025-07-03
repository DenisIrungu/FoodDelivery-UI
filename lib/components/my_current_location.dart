import 'package:flutter/material.dart';

class MyCurrentLocation extends StatelessWidget {
  const MyCurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    void openLocationSearchBox(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Your Location'),
                content: TextField(
                  decoration: InputDecoration(hintText: 'Search address...'),
                ),
                actions: [
                  //Cancel Button
                  MaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  //Save Button
                  MaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Save'),
                  )
                ],
              ));
    }

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deliver Now',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary, fontSize: 20),
          ),
          GestureDetector(
            onTap: () => openLocationSearchBox(context),
            child: Row(
              children: [
                Text(
                  'Uhuru street no 14, Bumber',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                Icon(Icons.keyboard_arrow_down_rounded)
              ],
            ),
          )
        ],
      ),
    );
  }
}
