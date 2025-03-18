import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({
    super.key,
  });

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Help"),
        ),
        body: SafeArea(
            child: Center(
                child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(children: const [
            Text(
              "Managing your Transactions",
              style: TextStyle(fontSize: 35),
            ),
            ExpansionTile(
                title: Text('Adding Transactions'),
                children: <Widget>[
                  Text(
                      'Press on the "Add Transaction" button in the bottom-right of the application. The application will navigate to the transaction entry screen. Appropriately enter transaction details, including the value, date, and category of a transaction, and press the "checkmark" button in the upper-right corner.'),
                ]),
            ExpansionTile(
                title: Text('Deleting Transactions'),
                children: <Widget>[
                  Text(
                      'Navigate to the "Transactions" screen using the bottom navigation bar. Locate a transaction to be removed, and swipe it from the list. The transaction will be removed from the screen and deleted from the application database.'),
                ]),
            ExpansionTile(
                title: Text('Editing Transactions'),
                children: <Widget>[
                  Text(
                      'Navigate to the "Transactions" screen using the bottom navigation bar. Locate a transaction to be edited, and tap on it. The application will navigate to the transaction editing screen, in which you can edit various details. Press the "checkmark" button in the upper right corner to submit.'),
                ]),
          ]),
        ))));
  }
}
