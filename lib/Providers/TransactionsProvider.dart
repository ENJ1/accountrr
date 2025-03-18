import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'DBProvider.dart';
part 'TransactionsProvider.g.dart';

class Transaction {
  Transaction(
      {required this.id,
      required this.date,
      required this.title,
      required this.description,
      required this.category,
      required this.value});

  final int id;
  final DateTime date;
  final String title;
  final String description;
  final double value;
  final String category;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date.toString(),
      'title': title,
      'description': description,
      'value': value,
      'category': category
    };
  }
}

@Riverpod()
class Transactions extends _$Transactions {
  @override
  Future<List<Transaction>> build() async {
    final List<Map<String, Object?>> transactionMaps =
        await ref.watch(dbProvider).value!.query(
              'TRANSACTIONS',
            ); // Retrieve all transactions recorded in database

    List<Transaction> transactions = [
      for (final transaction in transactionMaps)
        Transaction(
            id: transaction['id'] as int,
            title: transaction['title'] as String,
            date: DateTime.parse(transaction['date'] as String),
            description: transaction['description'] as String,
            category: transaction['category'] as String,
            value: transaction['value'] as double),
    ]; // Iterate throughout all retrieved transactions and map to a "Transaction" object

    transactions.sort(
      (a, b) => b.date.millisecondsSinceEpoch
          .compareTo(a.date.millisecondsSinceEpoch),
    ); // Sort List<Transaction> by chronological order (earliest to latest)

    return transactions; // Return sorted transactions
  }

  Future<Transaction> getTransaction(int id) async {
    final List<Map<String, Object?>> transactionMaps =
        await ref.read(dbProvider).value!.query(
      'TRANSACTIONS',
      where: 'id = ?',
      whereArgs: [id],
    );

    return [
      for (final transaction in transactionMaps)
        Transaction(
            id: transaction['id'] as int,
            title: transaction['title'] as String,
            date: DateTime.parse(transaction['date'] as String),
            description: transaction['description'] as String,
            category: transaction['category'] as String,
            value: transaction['value'] as double),
    ][0];
  }

  void addTransaction(Transaction transaction) {
    ref.read(dbProvider).when(
        // Retrieve a handle to the databaseProvider
        data: (data) {
          data.insert(
              "TRANSACTIONS",
              transaction
                  .toMap()); // Insert a row into the database, mapping each element of the "Transaction" class to a column
        },
        loading: () {},
        error: (object, stack) {});

    ref.invalidateSelf(); // Force the TransactionProvider to reload its state and update the UI
  }

  void editTransaction(Transaction transaction) {
    deleteTransaction(transaction.id);
    addTransaction(transaction);

    ref.invalidateSelf();
  }

  void deleteTransaction(int id) {
    ref.read(dbProvider).when(
        data: (data) {
          data.delete("TRANSACTIONS", where: 'id = ?', whereArgs: [id]);
        },
        loading: () {},
        error: (object, stack) {});

    ref.invalidateSelf();
  }

  void filterTransactions(
      String query, String category, dynamic dateAfter, dynamic dateBefore) {
    state = const AsyncValue.loading();

    List<Transaction> transactions = state.value!;

    if (query.isNotEmpty) {
      transactions = transactions
          .where((transaction) =>
              transaction.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else if (query.isNotEmpty) {
      transactions = transactions
          .where((transaction) => transaction.description
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    } else if (category.isNotEmpty) {
      transactions = transactions
          .where((transaction) => transaction.category == category)
          .toList();
    } else if (!(dateAfter == null)) {
      transactions = transactions
          .where((transaction) =>
              transaction.date.millisecondsSinceEpoch >
              dateAfter.millisecondsSinceEpoch)
          .toList();
    } else if (!(dateBefore == null)) {
      transactions = transactions
          .where((transaction) =>
              transaction.date.millisecondsSinceEpoch <
              dateBefore.millisecondsSinceEpoch)
          .toList();
    }

    state = AsyncValue.data(transactions);
  }
}
