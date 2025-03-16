import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
part 'DBProvider.g.dart';

@Riverpod()
class db extends _$db {
  @override
  Future<Database> build() async {
    var databasesPath = await getApplicationSupportDirectory();
    String path = join(databasesPath.path, 'accountrr.db');

// open the database
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE TRANSACTIONS (id INTEGER PRIMARY KEY, date TEXT, title TEXT, description TEXT, category TEXT, value REAL)');
    });
  }
}
