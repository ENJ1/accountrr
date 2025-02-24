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
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat.MMMMEEEEd().format(DateTime.now()),
                ),
              ),
              Row(
                children: [
                  Expanded(
                      flex: 9,
                      child: Text(
                        (DateTime.now().hour < 12
                                ? "Good Morning"
                                : "Good Afternoon") +
                            ", Ethan",
                        style: TextStyle(fontSize: 25),
                      )),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        context.push("/search");
                      },
                      icon: Icon(Icons.settings),
                      splashColor: Colors.transparent,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
              height: 150,
              child: Card(
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
                                child: Column(children: [
                                  ref.watch(balanceProvider).when(
                                      data: (data) => Text(
                                            data.toString(),
                                            style: TextStyle(fontSize: 25),
                                          ),
                                      error: (object, stack) => Text(
                                          object.toString() + stack.toString()),
                                      loading: () =>
                                          CircularProgressIndicator()),
                                  Text(
                                    "\u25B2 10%",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ])),
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
                child: Card(
                    color: Color.fromARGB(255, 218, 224, 255),
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
                              child: Column(children: [
                                ref.watch(transactionsProvider).when(
                                    data: (data) => Text(
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
                                    loading: () => CircularProgressIndicator()),
                                Text(
                                  "\u25B2 4%",
                                  style: TextStyle(fontSize: 10),
                                )
                              ])),
                        ])))),
            Expanded(
                child: Expanded(
                    child: Card(
                        color: Color.fromARGB(199, 255, 225, 222),
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
                                  child: Column(children: [
                                    ref.watch(transactionsProvider).when(
                                        data: (data) => Text(
                                              [
                                                for (final transaction in data)
                                                  (transaction.value < 0)
                                                      ? transaction.value
                                                      : 0
                                              ].sum.toString(),
                                              style: TextStyle(fontSize: 25),
                                            ),
                                        error: (object, stack) => Text(
                                            object.toString() +
                                                stack.toString()),
                                        loading: () =>
                                            CircularProgressIndicator()),
                                    Text(
                                      "\u25B2 0%",
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ])),
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
        SliverFixedExtentList(
          itemExtent: 150,
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index <= 2) {
                return Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: TransactionCard(
                        title: "Lunch with Anna",
                        date: "10/15/24",
                        value: "-26.34"));
              } else {
                return null;
              }
            },
          ),
        ),
      ]),
    )));
  }
}
