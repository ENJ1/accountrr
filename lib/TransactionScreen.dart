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
                        child: Text(
                          "Your Transactions",
                          style: TextStyle(fontSize: 25),
                        )),
                  ),
                  ref.watch(transactionsProvider).when(
                      data: (data) => SliverFixedExtentList(
                          itemExtent: 160,
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

                                        this.dispose();
                                      },
                                      key: Key(transaction.id.toString()),
                                      child: TransactionCard(
                                          title: transaction.title,
                                          date: transaction.date.toString(),
                                          value:
                                              transaction.value.toString()))),
                          ])),
                      error: (object, stack) => SliverToBoxAdapter(
                          child: Text(object.toString() + stack.toString())),
                      loading: () => SliverToBoxAdapter(
                          child: CircularProgressIndicator()))
                ]))));
  }
}
