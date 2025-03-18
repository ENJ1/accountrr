import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../Partials/TransactionCard.dart';
import '../Providers/TransactionsProvider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomScrollView(slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: SizedBox(
                        height: 65,
                        child: Row(children: [
                          const Expanded(
                              child: Text(
                            "Your Transactions",
                            style: TextStyle(fontSize: 25),
                          )),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {
                              final formKey = GlobalKey<FormBuilderState>();

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                        title:
                                            const Text("Filter Transactions"),
                                        children: [
                                          FormBuilder(
                                              key: formKey,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: FormBuilderTextField(
                                                      initialValue: "",
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  "Search",
                                                              border:
                                                                  OutlineInputBorder()),
                                                      name: "search",
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child:
                                                          FormBuilderDropdown(
                                                              hint: const Text(
                                                                  "Category"),
                                                              initialValue: "",
                                                              name: "category",
                                                              items: const [
                                                            DropdownMenuItem(
                                                                value:
                                                                    "groceries",
                                                                child: Text(
                                                                    "Groceries")),
                                                            DropdownMenuItem(
                                                                value: "food",
                                                                child: Text(
                                                                    "Food")),
                                                            DropdownMenuItem(
                                                                value:
                                                                    "online_shopping",
                                                                child: Text(
                                                                    "Online Shopping")),
                                                            DropdownMenuItem(
                                                                value: "income",
                                                                child: Text(
                                                                    "Income")),
                                                          ])),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
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
                                                      const Spacer(flex: 10),
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
                                                  child: const Text("Reset")),
                                              TextButton(
                                                  onPressed: () {
                                                    formKey.currentState
                                                        ?.saveAndValidate();

                                                    ref
                                                        .read(
                                                            transactionsProvider
                                                                .notifier)
                                                        .filterTransactions(
                                                            formKey.currentState
                                                                    ?.value[
                                                                "search"],
                                                            formKey.currentState
                                                                    ?.value[
                                                                "category"],
                                                            formKey.currentState
                                                                    ?.value[
                                                                "date_after"],
                                                            formKey.currentState
                                                                    ?.value[
                                                                "date_before"]);
                                                  },
                                                  child: const Text("Apply"))
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
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
                      loading: () => const SliverToBoxAdapter(
                          child: CircularProgressIndicator()))
                ]))));
  }
}
