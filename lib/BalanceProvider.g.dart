// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BalanceProvider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$balanceHash() => r'1ee48e62c4027e950a430ede7bd3e4cc2acbb149';

/// See also [Balance].
@ProviderFor(Balance)
final balanceProvider =
    AutoDisposeAsyncNotifierProvider<Balance, double>.internal(
  Balance.new,
  name: r'balanceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$balanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Balance = AutoDisposeAsyncNotifier<double>;
String _$balanceHistoryHash() => r'17e7a50b9bc9ae085feb4dbeb75f5839006fc64d';

/// See also [BalanceHistory].
@ProviderFor(BalanceHistory)
final balanceHistoryProvider =
    AutoDisposeAsyncNotifierProvider<BalanceHistory, List<double>>.internal(
  BalanceHistory.new,
  name: r'balanceHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$balanceHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BalanceHistory = AutoDisposeAsyncNotifier<List<double>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
