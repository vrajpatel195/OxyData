import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../entity/app_entity.dart';

part 'app_db.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'oxydata.sqlite'));
    print("File Path --> ${path.join(dbFolder.path, 'oxydata.sqlite')}");

    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [OxyDatabase])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  //Get the list of employee
  Future<int> insertOxyData(OxyDatabaseCompanion entity) {
    return into(oxyDatabase).insert(entity);
  }

  Future<List<OxyDatabaseData>> getAllOxyData() {
    return select(oxyDatabase).get();
  }

  Future<List<OxyDatabaseData>> getDataByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(oxyDatabase)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startOfDay) &
              tbl.recordedAt.isSmallerOrEqualValue(endOfDay)))
        .get();
  }

  // Future<void> deleteAllData() async {
  //   await delete(oxyDatabase).go();
  // }
}














































// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:drift_sqflite/drift_sqflite.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// part 'app_db.g.dart';

// @DataClassName('PurityData')
// class PurityDatas extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   IntColumn get purity => integer()();
//   IntColumn get flowRate => integer()();
//   IntColumn get pressure => integer()();
//   IntColumn get temperature => integer()();
//   TextColumn get serialNo => text()();
//   DateTimeColumn get recordedAt => dateTime().nullable()();
// }

// @DriftDatabase(tables: [AppDb])
// class AppDb extends _$AppDb {
//   AppDb() : super(_openConnection());

//   @override
//   int get schemaVersion => 1;

//   Future<int> insertPurityData(PurityDatasCompanion entity) {
//     return into(purityDatas).insert(entity);
//   }

//   Future<List<PurityData>> getAllPurityData() {
//     return select(purityDatas).get();
//   }
// }

// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'purity.sqlite'));
//     return NativeDatabase(file);
//   });
// }
