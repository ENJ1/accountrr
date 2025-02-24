import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'TransactionsProvider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({
    super.key,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

enum transactionStatus { MoneyIn, MoneyOut }

var selection = transactionStatus.MoneyIn;

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _transactionStatusKey = Key("segmentedbutton");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(Icons.close)),
          title: Text("Add a Transaction"),
          actions: [
            IconButton(
                onPressed: () {
                  _formKey.currentState?.saveAndValidate();

                  ref.watch(transactionsProvider.notifier).addTransaction(
                      Transaction(
                          id: DateTime.now().microsecondsSinceEpoch,
                          date: _formKey.currentState?.value["date"],
                          title: _formKey.currentState?.value["title"],
                          notes: _formKey.currentState?.value["description"],
                          value: (selection == transactionStatus.MoneyIn)
                              ? double.parse(
                                  _formKey.currentState?.value["value"])
                              : double.parse(
                                      _formKey.currentState?.value["value"]) *
                                  -1));

                  context.pop();
                },
                icon: Icon(Icons.check)),
          ],
        ),
        body: SafeArea(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: SingleChildScrollView(
                        child: FormBuilder(
                      key: _formKey,
                      child: Column(children: [
                        SegmentedButton<transactionStatus>(
                          selected: <transactionStatus>{selection},
                          onSelectionChanged:
                              (Set<transactionStatus> newSelection) {
                            setState(() {
                              // By default there is only a single segment that can be
                              // selected at one time, so its value is always the first
                              // item in the selected set.
                              selection = newSelection.first;
                            });
                          },
                          segments: const <ButtonSegment<transactionStatus>>[
                            ButtonSegment(
                              icon: Icon(Icons.arrow_upward),
                              label: Text("Money In"),
                              value: transactionStatus.MoneyIn,
                            ),
                            ButtonSegment(
                              icon: Icon(Icons.arrow_downward),
                              label: Text("Money Out"),
                              value: transactionStatus.MoneyOut,
                            ),
                          ],
                        ),
                        FormBuilderTextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          name: "value",
                          decoration: InputDecoration(
                              hintText: "100", prefixText: "\$"),
                          style: TextStyle(
                            fontSize: 125,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: FormBuilderTextField(
                            decoration: InputDecoration(
                                labelText: "Title",
                                border: OutlineInputBorder()),
                            name: "title",
                          ),
                        ),
                        FormBuilderTextField(
                          decoration: InputDecoration(
                              labelText: "Description",
                              border: OutlineInputBorder()),
                          name: "description",
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: FormBuilderDateTimePicker(
                              initialValue: DateTime.now(),
                              inputType: InputType.date,
                              format: DateFormat.yMEd(),
                              name: "date",
                              initialDate: DateTime.now(),
                            ))
                      ]),
                    ))))));
  }
}
