import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Partials/TransactionCard.dart';
import '../Providers/TransactionsProvider.dart';
import 'package:collection/collection.dart';
import '../Providers/BalanceProvider.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                "${DateTime.now().hour < 12 ? "Good Morning" : "Good Afternoon"}, Ethan",
                style: const TextStyle(fontSize: 25),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
              height: 150,
              child: Card.outlined(
                  child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(children: [
                        Expanded(
                          flex: 40,
                          child: Column(children: [
                            const Expanded(
                              flex: 15,
                              child: Text(
                                "Account Balance",
                              ),
                            ),
                            const Spacer(flex: 15),
                            Expanded(
                              flex: 70,
                              child: ref.watch(balanceProvider).when(
                                  data: (data) => Text(
                                        "\$$data",
                                        style: const TextStyle(fontSize: 25),
                                      ),
                                  error: (object, stack) => Text(
                                      object.toString() + stack.toString()),
                                  loading: () =>
                                      const CircularProgressIndicator()),
                            ),
                          ]),
                        ),
                        const Spacer(flex: 10),
                        Expanded(
                            flex: 50,
                            child: ref.watch(balanceHistoryProvider).when(
                                data: (data) => LineChart(LineChartData(
                                        borderData: FlBorderData(
                                          border: const Border(),
                                        ),
                                        titlesData: const FlTitlesData(
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
                                        gridData: const FlGridData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                              dotData: const FlDotData(
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
                                loading: () =>
                                    const CircularProgressIndicator())),
                      ])))),
        ),
        SliverToBoxAdapter(
            child: SizedBox(
          height: 150,
          child: Row(children: [
            Expanded(
                child: Card.outlined(
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          const Expanded(
                            flex: 20,
                            child: Text("Money In"),
                          ),
                          const Spacer(flex: 20),
                          Expanded(
                              flex: 60,
                              child: ref.watch(transactionsProvider).when(
                                  data: (data) => Text(
                                        "\$${[
                                          for (final transaction in data)
                                            (transaction.value > 0)
                                                ? transaction.value
                                                : 0
                                        ].sum}",
                                        style: const TextStyle(fontSize: 25),
                                      ),
                                  error: (object, stack) => Text(
                                      object.toString() + stack.toString()),
                                  loading: () =>
                                      const CircularProgressIndicator())),
                        ])))),
            Expanded(
                child: Expanded(
                    child: Card.outlined(
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(children: [
                              const Expanded(
                                flex: 20,
                                child: Text("Money Out"),
                              ),
                              const Spacer(flex: 20),
                              Expanded(
                                flex: 60,
                                child: ref.watch(transactionsProvider).when(
                                    data: (data) => Text(
                                          "\$${[
                                            for (final transaction in data)
                                              (transaction.value < 0)
                                                  ? transaction.value
                                                  : 0
                                          ].sum}",
                                          style: const TextStyle(fontSize: 25),
                                        ),
                                    error: (object, stack) => Text(
                                        object.toString() + stack.toString()),
                                    loading: () =>
                                        const CircularProgressIndicator()),
                              ),
                            ])))))
          ]),
        )),
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        "Recent Transactions",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(
                        child: TextButton(
                            onPressed: () {},
                            style: const ButtonStyle(
                                splashFactory: NoSplash.splashFactory),
                            child: const Text(
                              "SHOW ALL",
                              style: TextStyle(fontSize: 10),
                            ))),
                  ],
                )),
          ),
        ),
        ref.watch(transactionsProvider).when(
            data: (data) => SliverList(
                    delegate: SliverChildListDelegate([
                  for (final transaction in data.take(3))
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Dismissible(
                            onDismissed: (DismissDirection) {
                              ref
                                  .watch(transactionsProvider.notifier)
                                  .deleteTransaction(transaction.id);

                              dispose();
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
                const SliverToBoxAdapter(child: CircularProgressIndicator()))
      ]),
    )));
  }
}
