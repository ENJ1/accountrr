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
import 'dart:core';

class EditTransactionScreen extends ConsumerStatefulWidget {
  EditTransactionScreen({super.key, this.id = 0});

  int id;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

enum transactionStatus { MoneyIn, MoneyOut }

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  var selection = transactionStatus.MoneyIn;

  @override
  Widget build(BuildContext context) {
    if (widget.id != 0) {
      return FutureBuilder(
          future:
              ref.read(transactionsProvider.notifier).getTransaction(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(Icons.close)),
                    title: Text("Edit Transaction"),
                    actions: [
                      IconButton(
                          onPressed: () {
                            _formKey.currentState?.saveAndValidate();
                            ref
                                .read(transactionsProvider.notifier)
                                .editTransaction(Transaction(
                                    id: snapshot
                                        .data!.date.microsecondsSinceEpoch,
                                    date: _formKey.currentState?.value["date"],
                                    title:
                                        _formKey.currentState?.value["title"],
                                    description: _formKey
                                        .currentState?.value["description"],
                                    category: _formKey
                                        .currentState?.value["category"],
                                    value:
                                        (selection == transactionStatus.MoneyIn)
                                            ? double.parse(_formKey
                                                .currentState?.value["value"])
                                            : double.parse(_formKey.currentState
                                                    ?.value["value"]) *
                                                -1));

                            context.pop();
                          },
                          icon: Icon(Icons.check)),
                    ],
                  ),
                  body: SafeArea(
                      child: Center(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 40),
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
                                    segments: const <ButtonSegment<
                                        transactionStatus>>[
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
                                  IntrinsicWidth(
                                    child: FormBuilderTextField(
                                      initialValue: [
                                        snapshot.data!.value.toString()
                                      ][0],
                                      showCursor: false,
                                      keyboardType: TextInputType.number,
                                      name: "value",
                                      decoration: InputDecoration(
                                          hintText: "100",
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.attach_money)),
                                      style: TextStyle(
                                        fontSize: 125,
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                      ]),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: FormBuilderTextField(
                                      initialValue: snapshot.data!.title,
                                      decoration: InputDecoration(
                                          labelText: "Title",
                                          border: OutlineInputBorder()),
                                      name: "title",
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: FormBuilderTextField(
                                      initialValue: snapshot.data!.description,
                                      decoration: InputDecoration(
                                          labelText: "Description",
                                          border: OutlineInputBorder()),
                                      name: "description",
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Row(children: [
                                      Expanded(
                                        flex: 40,
                                        child: FormBuilderDateTimePicker(
                                          initialValue: snapshot.data!.date,
                                          inputType: InputType.date,
                                          format: DateFormat.yMEd(),
                                          name: "date",
                                        ),
                                      ),
                                      Spacer(flex: 10),
                                      Expanded(
                                          flex: 40,
                                          child: FormBuilderDropdown(
                                              initialValue:
                                                  snapshot.data!.category,
                                              name: "category",
                                              items: [
                                                DropdownMenuItem(
                                                    child: Text("Groceries"),
                                                    value: "groceries"),
                                                DropdownMenuItem(
                                                    child: Text("Food"),
                                                    value: "food"),
                                                DropdownMenuItem(
                                                    child:
                                                        Text("Online Shopping"),
                                                    value: "online_shopping"),
                                                DropdownMenuItem(
                                                    child: Text("Income"),
                                                    value: "income"),
                                              ]))
                                    ]),
                                  )
                                ]),
                              )))));
            } else if (snapshot.hasError) {
              return Icon(Icons.error);
            } else {
              return CircularProgressIndicator();
            }
          });
    } else {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.close)),
            title: Text("Edit Transaction"),
            actions: [
              IconButton(
                  onPressed: () {
                    _formKey.currentState?.saveAndValidate();
                    ref.read(transactionsProvider.notifier).addTransaction(
                        Transaction(
                            id: DateTime.now().microsecondsSinceEpoch,
                            date: _formKey.currentState?.value["date"],
                            title: _formKey.currentState?.value["title"],
                            description:
                                _formKey.currentState?.value["description"],
                            category: _formKey.currentState?.value["category"],
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                          IntrinsicWidth(
                            child: FormBuilderTextField(
                              initialValue: "100",
                              showCursor: false,
                              keyboardType: TextInputType.number,
                              name: "value",
                              decoration: InputDecoration(
                                  hintText: "100",
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.attach_money)),
                              style: TextStyle(
                                fontSize: 125,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: FormBuilderTextField(
                              decoration: InputDecoration(
                                  labelText: "Title",
                                  border: OutlineInputBorder()),
                              name: "title",
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: FormBuilderTextField(
                              decoration: InputDecoration(
                                  labelText: "Description",
                                  border: OutlineInputBorder()),
                              name: "description",
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(children: [
                              Expanded(
                                flex: 40,
                                child: FormBuilderDateTimePicker(
                                  inputType: InputType.date,
                                  format: DateFormat.yMEd(),
                                  name: "date",
                                ),
                              ),
                              Spacer(flex: 10),
                              Expanded(
                                  flex: 40,
                                  child: FormBuilderDropdown(
                                      name: "category",
                                      items: [
                                        DropdownMenuItem(
                                            child: Text("Groceries"),
                                            value: "groceries"),
                                        DropdownMenuItem(
                                            child: Text("Food"), value: "food"),
                                        DropdownMenuItem(
                                            child: Text("Online Shopping"),
                                            value: "online_shopping"),
                                        DropdownMenuItem(
                                            child: Text("Income"),
                                            value: "income"),
                                      ]))
                            ]),
                          )
                        ]),
                      )))));
    }
  }
}
