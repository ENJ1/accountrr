import 'dart:math';

import 'package:flutter/foundation.dart';
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
    ];
  }

  Future<Transaction> getTransaction(int id) async {
    final List<Map<String, Object?>> transactionMaps =
        await ref.watch(dbProvider).value!.query(
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
    ref.watch(dbProvider).when(
        data: (data) {
          data.insert("TRANSACTIONS", transaction.toMap());
        },
        loading: () {},
        error: (object, stack) {});

    ref.invalidateSelf();
  }

  void editTransaction(Transaction transaction) {
    ref.watch(dbProvider).when(
        data: (data) {
          data.update("TRANSACTIONS", transaction.toMap(),
              where: 'id = ?', whereArgs: [transaction.id]);
        },
        loading: () {},
        error: (object, stack) {});

    ref.invalidateSelf();
  }

  void deleteTransaction(int id) {
    ref.watch(dbProvider).when(
        data: (data) {
          data.delete("TRANSACTIONS", where: 'id = ?', whereArgs: [id]);
        },
        loading: () {},
        error: (object, stack) {});

    ref.invalidateSelf();
  }

  void filterTransactions(
      String query, String category, dynamic date_after, dynamic date_before) {
    state = AsyncValue.loading();

    List<Transaction> transactions = state.value!;

    if (!query.isEmpty) {
      transactions = transactions
          .where((transaction) =>
              transaction.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else if (!query.isEmpty) {
      transactions = transactions
          .where((transaction) => transaction.description
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    } else if (!category.isEmpty) {
      transactions = transactions
          .where((transaction) => transaction.category == category)
          .toList();
    } else if (!(date_after == null)) {
      transactions = transactions
          .where((transaction) =>
              transaction.date.millisecondsSinceEpoch >
              date_after.millisecondsSinceEpoch)
          .toList();
    } else if (!(date_before == null)) {
      transactions = transactions
          .where((transaction) =>
              transaction.date.millisecondsSinceEpoch <
              date_before.millisecondsSinceEpoch)
          .toList();
    }

    state = AsyncValue.data(transactions);
  }
}
