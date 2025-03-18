import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'TransactionsProvider.dart';
import 'package:collection/collection.dart';
part 'BalanceProvider.g.dart';

@Riverpod()
class Balance extends _$Balance {
  // Provides current balance for use across application
  @override
  Future<double> build() async {
    final transactions = ref.watch(transactionsProvider).value!;

    return [for (final transaction in transactions) transaction.value]
        .sum; // Retrieve all transaction values and sum them
  }
}

@Riverpod()
class BalanceHistory extends _$BalanceHistory {
  // Provides full history of delta balances for plotting on graph
  @override
  Future<List<double>> build() async {
    final transactions = ref.watch(transactionsProvider).value!;

    return [
      for (var transaction in transactions)
        transactions.indexOf(transaction) == 0
            ? transaction.value
            : transactions[transactions.indexOf(transaction) - 1].value +
                transaction.value
    ];
  }
}
