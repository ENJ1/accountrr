import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../Providers/TransactionsProvider.dart';
import 'dart:core';

class EditTransactionScreen extends ConsumerStatefulWidget {
  EditTransactionScreen({super.key, this.id = 0});

  int id; // Provided transaction ID (if editing transaction)

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

enum transactionStatus { MoneyIn, MoneyOut } // SelectionButton options

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<
      FormBuilderState>(); // Global reference to form for later access
  var selection = transactionStatus.MoneyIn; // Default SelectionButton status

  @override
  Widget build(BuildContext context) {
    if (widget.id != 0) {
      // If a widget ID is provided, signifying an edit operation
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
                        icon: const Icon(Icons.close)),
                    title: const Text("Edit Transaction"),
                    actions: [
                      IconButton(
                          onPressed: () {
                            _formKey.currentState?.saveAndValidate();
                            ref
                                .read(transactionsProvider.notifier)
                                .editTransaction(Transaction(
                                    id: snapshot
                                        .data!.date.millisecondsSinceEpoch,
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
                          icon: const Icon(Icons.check)),
                    ],
                  ),
                  body: SafeArea(
                      child: Center(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
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
                                      decoration: const InputDecoration(
                                          hintText: "100",
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.attach_money)),
                                      style: const TextStyle(
                                        fontSize: 125,
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                        FormBuilderValidators.numeric()
                                      ]),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: FormBuilderTextField(
                                      initialValue: snapshot.data!.title,
                                      decoration: const InputDecoration(
                                          labelText: "Title",
                                          border: OutlineInputBorder()),
                                      name: "title",
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                      ]),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: FormBuilderTextField(
                                      initialValue: snapshot.data!.description,
                                      decoration: const InputDecoration(
                                          labelText: "Description",
                                          border: OutlineInputBorder()),
                                      name: "description",
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                      ]),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(children: [
                                      Expanded(
                                        flex: 40,
                                        child: FormBuilderDateTimePicker(
                                          fieldHintText: "Date",
                                          initialValue: snapshot.data!.date,
                                          inputType: InputType.date,
                                          format: DateFormat.yMEd(),
                                          name: "date",
                                          validator:
                                              FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.dateTime()
                                          ]),
                                        ),
                                      ),
                                      const Spacer(flex: 10),
                                      Expanded(
                                          flex: 40,
                                          child: FormBuilderDropdown(
                                            hint: const Text("Category"),
                                            initialValue:
                                                snapshot.data!.category,
                                            name: "category",
                                            items: const [
                                              DropdownMenuItem(
                                                  value: "groceries",
                                                  child: Text("Groceries")),
                                              DropdownMenuItem(
                                                  value: "food",
                                                  child: Text("Food")),
                                              DropdownMenuItem(
                                                  value: "online_shopping",
                                                  child:
                                                      Text("Online Shopping")),
                                              DropdownMenuItem(
                                                  value: "income",
                                                  child: Text("Income")),
                                            ],
                                            validator:
                                                FormBuilderValidators.compose([
                                              FormBuilderValidators.required(),
                                            ]),
                                          ))
                                    ]),
                                  )
                                ]),
                              )))));
            } else if (snapshot.hasError) {
              return const Icon(Icons.error);
            } else {
              return const CircularProgressIndicator();
            }
          });
    } else {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.close)),
            title: const Text("Edit Transaction"),
            actions: [
              IconButton(
                  onPressed: () {
                    _formKey.currentState?.saveAndValidate();
                    ref.read(transactionsProvider.notifier).addTransaction(
                        Transaction(
                            id: DateTime.now().millisecondsSinceEpoch,
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
                  icon: const Icon(Icons.check)),
            ],
          ),
          body: SafeArea(
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
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
                              showCursor: false,
                              keyboardType: TextInputType.number,
                              name: "value",
                              decoration: const InputDecoration(
                                  hintText: "100",
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.attach_money)),
                              style: const TextStyle(
                                fontSize: 125,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.numeric()
                              ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: FormBuilderTextField(
                              decoration: const InputDecoration(
                                  labelText: "Title",
                                  border: OutlineInputBorder()),
                              name: "title",
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: FormBuilderTextField(
                              decoration: const InputDecoration(
                                  labelText: "Description",
                                  border: OutlineInputBorder()),
                              name: "description",
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(children: [
                              Expanded(
                                flex: 40,
                                child: FormBuilderDateTimePicker(
                                  fieldHintText: "Date",
                                  inputType: InputType.date,
                                  format: DateFormat.yMEd(),
                                  name: "date",
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.dateTime()
                                  ]),
                                ),
                              ),
                              const Spacer(flex: 10),
                              Expanded(
                                  flex: 40,
                                  child: FormBuilderDropdown(
                                    hint: const Text("Category"),
                                    name: "category",
                                    items: const [
                                      DropdownMenuItem(
                                          value: "groceries",
                                          child: Text("Groceries")),
                                      DropdownMenuItem(
                                          value: "food", child: Text("Food")),
                                      DropdownMenuItem(
                                          value: "online_shopping",
                                          child: Text("Online Shopping")),
                                      DropdownMenuItem(
                                          value: "income",
                                          child: Text("Income")),
                                    ],
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                  ))
                            ]),
                          )
                        ]),
                      )))));
    }
  }
}
