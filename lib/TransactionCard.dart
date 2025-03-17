import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard(
      {super.key,
      required this.title,
      required this.date,
      required this.value,
      required this.description,
      required this.category,
      required this.onClick});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final DateTime date;
  final String value;
  final String description;
  final String category;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onClick,
        child: ExpansionTile(
          title: Text(title),
          subtitle: Text(
            DateFormat("MM-dd-yyyy").format(date).toString() + " • " + category,
            style: TextStyle(fontSize: 10.0),
          ),
          trailing: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$" + value,
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ])),
          children: [Text(description)],
        ));
  }
}
