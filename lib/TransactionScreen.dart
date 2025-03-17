import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'TransactionCard.dart';
import 'TransactionsProvider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({
    super.key,
  });

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomScrollView(slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: SizedBox(
                        height: 65,
                        child: Row(children: [
                          Expanded(
                              child: Text(
                            "Your Transactions",
                            style: TextStyle(fontSize: 25),
                          )),
                          IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () {
                              final _formKey = GlobalKey<FormBuilderState>();

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                        title: Text("Filter Transactions"),
                                        children: [
                                          FormBuilder(
                                              key: _formKey,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: FormBuilderTextField(
                                                      initialValue: "",
                                                      decoration: InputDecoration(
                                                          labelText: "Search",
                                                          border:
                                                              OutlineInputBorder()),
                                                      name: "search",
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child:
                                                          FormBuilderDropdown(
                                                              hint: Text(
                                                                  "Category"),
                                                              initialValue: "",
                                                              name: "category",
                                                              items: [
                                                            DropdownMenuItem(
                                                                child: Text(
                                                                    "Groceries"),
                                                                value:
                                                                    "groceries"),
                                                            DropdownMenuItem(
                                                                child: Text(
                                                                    "Food"),
                                                                value: "food"),
                                                            DropdownMenuItem(
                                                                child: Text(
                                                                    "Online Shopping"),
                                                                value:
                                                                    "online_shopping"),
                                                            DropdownMenuItem(
                                                                child: Text(
                                                                    "Income"),
                                                                value:
                                                                    "income"),
                                                          ])),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5),
                                                    child: Row(children: [
                                                      Expanded(
                                                        flex: 40,
                                                        child:
                                                            FormBuilderDateTimePicker(
                                                          fieldHintText:
                                                              "After",
                                                          inputType:
                                                              InputType.date,
                                                          format:
                                                              DateFormat.yMEd(),
                                                          name: "date_after",
                                                        ),
                                                      ),
                                                      Spacer(flex: 10),
                                                      Expanded(
                                                        flex: 40,
                                                        child:
                                                            FormBuilderDateTimePicker(
                                                          fieldHintText:
                                                              "Before",
                                                          inputType:
                                                              InputType.date,
                                                          format:
                                                              DateFormat.yMEd(),
                                                          name: "date_before",
                                                        ),
                                                      )
                                                    ]),
                                                  ),
                                                ],
                                              )),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    ref.invalidate(
                                                        transactionsProvider);
                                                  },
                                                  child: Text("Reset")),
                                              TextButton(
                                                  onPressed: () {
                                                    _formKey.currentState
                                                        ?.saveAndValidate();

                                                    ref
                                                        .read(
                                                            transactionsProvider
                                                                .notifier)
                                                        .filterTransactions(
                                                            _formKey.currentState
                                                                    ?.value[
                                                                "search"],
                                                            _formKey.currentState
                                                                    ?.value[
                                                                "category"],
                                                            _formKey.currentState
                                                                    ?.value[
                                                                "date_after"],
                                                            _formKey.currentState
                                                                    ?.value[
                                                                "date_before"]);
                                                  },
                                                  child: Text("Apply"))
                                            ],
                                          )
                                        ]);
                                  });
                            },
                          ),
                        ])),
                  ),
                  ref.watch(transactionsProvider).when(
                      data: (data) => SliverList(
                              delegate: SliverChildListDelegate([
                            for (final transaction in data)
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Dismissible(
                                      onDismissed: (DismissDirection) {
                                        ref
                                            .watch(
                                                transactionsProvider.notifier)
                                            .deleteTransaction(transaction.id);
                                      },
                                      key: Key(transaction.id.toString()),
                                      child: TransactionCard(
                                          onClick: () {
                                            context.push(Uri(
                                                path: '/edit_transaction',
                                                queryParameters: {
                                                  'id':
                                                      transaction.id.toString()
                                                }).toString());
                                          },
                                          title: transaction.title,
                                          description: transaction.description,
                                          category: transaction.category,
                                          date: transaction.date,
                                          value: transaction.value.toString())))
                          ])),
                      error: (object, stack) => SliverToBoxAdapter(
                          child: Text(object.toString() + stack.toString())),
                      loading: () => SliverToBoxAdapter(
                          child: CircularProgressIndicator()))
                ]))));
  }
}
