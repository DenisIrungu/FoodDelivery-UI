import 'package:flutter/material.dart';

class MyDescriptionBox extends StatelessWidget {
  const MyDescriptionBox({super.key});

  @override
  Widget build(BuildContext context) {
    var myPrimaryStyle = TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary, fontSize: 17);
    var mySecondaryStyle =
        TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 17);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          )),
      padding: EdgeInsets.all(25),
      margin: EdgeInsets.only(left: 25, right: 25, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                '\$2.50',
                style: myPrimaryStyle,
              ),
              Text(
                'Delivery Fee',
                style: mySecondaryStyle,
              )
            ],
          ),
          Column(
            children: [
              Text(
                '15- 30 minutes',
                style: myPrimaryStyle,
              ),
              Text(
                'Delivery Time',
                style: mySecondaryStyle,
              )
            ],
          )
        ],
      ),
    );
  }
}
