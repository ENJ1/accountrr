import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'TransactionCard.dart';
import 'package:riverpod/riverpod.dart';
import 'TransactionsProvider.dart';
import 'package:collection/collection.dart';
import 'BalanceProvider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
            child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(
            height: 75,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                DateFormat.MMMMEEEEd().format(DateTime.now()),
              ),
              Text(
                (DateTime.now().hour < 12 ? "Good Morning" : "Good Afternoon") +
                    ", Ethan",
                style: TextStyle(fontSize: 25),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
              height: 150,
              child: Card.outlined(
                  child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(children: [
                        Expanded(
                          flex: 40,
                          child: Column(children: [
                            Expanded(
                              flex: 15,
                              child: Text(
                                "Account Balance",
                              ),
                            ),
                            Spacer(flex: 15),
                            Expanded(
                              flex: 70,
                              child: ref.watch(balanceProvider).when(
                                  data: (data) => Text(
                                        "\$" + data.toString(),
                                        style: TextStyle(fontSize: 25),
                                      ),
                                  error: (object, stack) => Text(
                                      object.toString() + stack.toString()),
                                  loading: () => CircularProgressIndicator()),
                            ),
                          ]),
                        ),
                        Spacer(flex: 10),
                        Expanded(
                            flex: 50,
                            child: ref.watch(balanceHistoryProvider).when(
                                data: (data) => LineChart(LineChartData(
                                        borderData: FlBorderData(
                                          border: const Border(),
                                        ),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                        ),
                                        gridData: FlGridData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                              dotData: FlDotData(
                                                show: false,
                                              ),
                                              spots: [
                                                for (var point in data)
                                                  FlSpot(
                                                      data
                                                          .indexOf(point)
                                                          .toDouble(),
                                                      point),
                                              ])
                                        ])),
                                error: (object, stack) =>
                                    Text(object.toString() + stack.toString()),
                                loading: () => CircularProgressIndicator())),
                      ])))),
        ),
        SliverToBoxAdapter(
            child: SizedBox(
          height: 150,
          child: Row(children: [
            Expanded(
                child: Card.outlined(
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(children: [
                          Expanded(
                            flex: 20,
                            child: Text("Money In"),
                          ),
                          Spacer(flex: 20),
                          Expanded(
                              flex: 60,
                              child: ref.watch(transactionsProvider).when(
                                  data: (data) => Text(
                                        "\$" +
                                            [
                                              for (final transaction in data)
                                                (transaction.value > 0)
                                                    ? transaction.value
                                                    : 0
                                            ].sum.toString(),
                                        style: TextStyle(fontSize: 25),
                                      ),
                                  error: (object, stack) => Text(
                                      object.toString() + stack.toString()),
                                  loading: () => CircularProgressIndicator())),
                        ])))),
            Expanded(
                child: Expanded(
                    child: Card.outlined(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(children: [
                              Expanded(
                                flex: 20,
                                child: Text("Money Out"),
                              ),
                              Spacer(flex: 20),
                              Expanded(
                                flex: 60,
                                child: ref.watch(transactionsProvider).when(
                                    data: (data) => Text(
                                          "\$" +
                                              [
                                                for (final transaction in data)
                                                  (transaction.value < 0)
                                                      ? transaction.value
                                                      : 0
                                              ].sum.toString(),
                                          style: TextStyle(fontSize: 25),
                                        ),
                                    error: (object, stack) => Text(
                                        object.toString() + stack.toString()),
                                    loading: () => CircularProgressIndicator()),
                              ),
                            ])))))
          ]),
        )),
        SliverPadding(
          padding: EdgeInsets.only(top: 8),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Recent Transactions",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(
                        child: TextButton(
                            child: Text(
                              "SHOW ALL",
                              style: TextStyle(fontSize: 10),
                            ),
                            onPressed: () {},
                            style: ButtonStyle(
                                splashFactory: NoSplash.splashFactory))),
                  ],
                )),
          ),
        ),
        ref.watch(transactionsProvider).when(
            data: (data) => SliverList(
                    delegate: SliverChildListDelegate([
                  for (final transaction in data.take(3))
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Dismissible(
                            onDismissed: (DismissDirection) {
                              ref
                                  .watch(transactionsProvider.notifier)
                                  .deleteTransaction(transaction.id);

                              this.dispose();
                            },
                            key: Key(transaction.id.toString()),
                            child: TransactionCard(
                                onClick: () {},
                                title: transaction.title,
                                description: transaction.description,
                                category: transaction.category,
                                date: transaction.date,
                                value: transaction.value.toString()))),
                ])),
            error: (object, stack) => SliverToBoxAdapter(
                child: Text(object.toString() + stack.toString())),
            loading: () =>
                SliverToBoxAdapter(child: CircularProgressIndicator()))
      ]),
    )));
  }
}
