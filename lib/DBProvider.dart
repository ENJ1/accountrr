import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'DBProvider.g.dart';

@Riverpod()
class db extends _$db {
  @override
  Future<SharedPreferences> build() async {
    return SharedPreferences.getInstance();

  }
}
