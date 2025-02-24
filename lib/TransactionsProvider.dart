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
      required this.notes,
      required this.value});

  final int id;
  final DateTime date;
  final String title;
  final String notes;
  final double value;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date.toString(),
      'title': title,
      'notes': notes,
      'value': value
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
            notes: transaction['notes'] as String,
            value: transaction['value'] as double),
    ];
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

  void deleteTransaction(int id) {
    ref.watch(dbProvider).when(
        data: (data) {
          data.delete("TRANSACTIONS", where: 'id = ?', whereArgs: [id]);
        },
        loading: () {},
        error: (object, stack) {});

    ref.invalidateSelf();
  }

  //void clearTransactions() async {
  //  return ref.watch(databaseProvider).when(data: (data) {});
  //}
}
