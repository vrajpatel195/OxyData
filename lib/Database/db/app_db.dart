import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../entity/alarm_entity.dart';
import '../entity/app_entity.dart';
import '../entity/limit_entity.dart';

part 'app_db.g.dart';

class AppDbSingleton {
  static final AppDbSingleton _instance = AppDbSingleton._internal();

  factory AppDbSingleton() => _instance;

  AppDbSingleton._internal();

  static AppDb? _appDb;

  Future<AppDb> get database async {
    _appDb ??= await _initDb();
    return _appDb!;
  }

  Future<AppDb> _initDb() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'oxydata.sqlite'));
    print("File Path --> ${path.join(dbFolder.path, 'oxydata.sqlite')}");

    return AppDb(NativeDatabase(file));
  }
}

@DriftDatabase(tables: [OxyDatabase, LimitSettingsTable, AlarmTable])
class AppDb extends _$AppDb {
  AppDb(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll(); // Create all tables
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            await m.createTable(
                limitSettingsTable); // Create the new table on upgrade
            await m.createTable(alarmTable); // Create AlarmTable during upgrade
          }
        },
      );

  Future<int> insertOxyData(OxyDatabaseCompanion entity) {
    return into(oxyDatabase).insert(entity);
  }

  Future<List<OxyDatabaseData>> getAllOxyData() {
    return select(oxyDatabase).get();
  }

// Function to get data for a date
  Future<List<OxyDatabaseData>> getDataByDate(DateTime date, String serialNo) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(oxyDatabase)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startOfDay) &
              tbl.recordedAt.isSmallerOrEqualValue(endOfDay) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

  // Function to get data for a week
  Future<List<OxyDatabaseData>> getDataByDateRange(
      DateTime startDate, DateTime endDate, String serialNo) {
    final startOfRange =
        DateTime(startDate.year, startDate.month, startDate.day);
    final endOfRange =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return (select(oxyDatabase)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startOfRange) &
              tbl.recordedAt.isSmallerOrEqualValue(endOfRange) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

  // Function to get data for a month
  Future<List<OxyDatabaseData>> getDataByMonth(
      DateTime monthDate, String serialNo) async {
    DateTime startDate;
    DateTime endDate;
    try {
      // Get the first and last days of the month
      startDate = DateTime(monthDate.year, monthDate.month, 1);
      endDate = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
    } catch (e) {
      print('Error parsing date: $e');
      return [];
    }

    return (select(oxyDatabase)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startDate) &
              tbl.recordedAt.isSmallerOrEqualValue(endDate) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

// insert limit setting data
  Future<int> insertLimitSetting(LimitSettingsTableCompanion entity) {
    return into(limitSettingsTable).insert(entity);
  }

//get the limit setting data by date
  Future<List<LimitSettingsTableData>> getLimitSettingsByDate(
      DateTime date, String serialNo) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(limitSettingsTable)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startOfDay) &
              tbl.recordedAt.isSmallerOrEqualValue(endOfDay) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

//get limits setting data by week
  Future<List<LimitSettingsTableData>> getLimitSettingsByWeek(
      DateTime startDate, DateTime endDate, String serialNo) async {
    final startOfWeek =
        DateTime(startDate.year, startDate.month, startDate.day);
    final endOfWeek =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return (select(limitSettingsTable)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startOfWeek) &
              tbl.recordedAt.isSmallerOrEqualValue(endOfWeek) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

//get limit setting data by month
  Future<List<LimitSettingsTableData>> getLimitSettingsByMonth(
      DateTime monthDate, String serialNo) async {
    DateTime startDate = DateTime(monthDate.year, monthDate.month, 1);
    DateTime endDate =
        DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
    return (select(limitSettingsTable)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startDate) &
              tbl.recordedAt.isSmallerOrEqualValue(endDate) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

  Future<Map<String, LimitSettingsTableData?>>
      getLatestLimitSettingsForAllTypesBeforeDate(
          DateTime selectDate, String serialNo) async {
    final types = ['Purity', 'Pressure', 'Temp', 'Flow'];

    final Map<String, LimitSettingsTableData?> results = {};

    // Calculate the previous date (one day before selectDate)
    final previousDate = selectDate.subtract(Duration(days: 1));

    for (String type in types) {
      // Query to get the latest record for the given type before or on the previousDate
      final query = select(limitSettingsTable)
        ..where((tbl) => tbl.type.equals(type) & tbl.serialNo.equals(serialNo))
        ..where((tbl) => tbl.recordedAt
            .isBetweenValues(previousDate, previousDate.add(Duration(days: 1))))
        ..orderBy([
          (tbl) =>
              OrderingTerm(expression: tbl.recordedAt, mode: OrderingMode.desc)
        ])
        ..limit(1);

      // Get the result
      LimitSettingsTableData? result = await query.getSingleOrNull();

      // Store the result for the current type
      results[type] = result;
    }

    return results;
  }

  Future<List<LimitSettingsTableData>> getAllLimitSettings() {
    return select(limitSettingsTable).get();
  }

// ALARM TABLE

// insert alarm data
  Future<int> insertAlarm(AlarmTableCompanion entity) {
    return into(alarmTable).insert(entity);
  }

// get alarm data by date
  Future<List<AlarmTableData>> getAlarmsByDate(
      DateTime date, String serialNo) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(alarmTable)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startOfDay) &
              tbl.recordedAt.isSmallerOrEqualValue(endOfDay) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

// insert alarm data by week
  Future<List<AlarmTableData>> getAlarmsByWeek(
      DateTime startDate, DateTime endDate, String serialNo) async {
    final startOfWeek =
        DateTime(startDate.year, startDate.month, startDate.day);
    final endOfWeek =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return (select(alarmTable)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startOfWeek) &
              tbl.recordedAt.isSmallerOrEqualValue(endOfWeek) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

// get alarm data by month
  Future<List<AlarmTableData>> getAlarmsByMonth(
      DateTime monthDate, String serialNo) async {
    DateTime startDate = DateTime(monthDate.year, monthDate.month, 1);
    DateTime endDate =
        DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
    return (select(alarmTable)
          ..where((tbl) =>
              tbl.recordedAt.isBiggerOrEqualValue(startDate) &
              tbl.recordedAt.isSmallerOrEqualValue(endDate) &
              tbl.serialNo.equals(serialNo)))
        .get();
  }

  // Get all alarms
  Future<List<AlarmTableData>> getAllAlarms() {
    return select(alarmTable).get();
  }

  // Function to delete all data from LimitSettingsTable
  Future<void> deleteAllLimitSettings() async {
    await delete(limitSettingsTable).go();
    await customUpdate('DELETE FROM sqlite_sequence WHERE name = ?',
        variables: [
          Variable.withString('limit_settings_table')
        ] // Use the actual table name
        );
    print("All limit settings have been deleted and ID counter reset.");
  }

// Function to delete all data from AlarmTable
  Future<void> deleteAllAlarms() async {
    await delete(alarmTable).go();
    await customUpdate('DELETE FROM sqlite_sequence WHERE name = ?',
        variables: [
          Variable.withString('alarm_table')
        ] // Use the actual table name
        );
    print("All Alarms have been deleted and ID counter reset.");
  }

  Future<List<String>> getAllSerialNumbers() async {
    // Query to get all distinct serial numbers
    final query = (selectOnly(oxyDatabase, distinct: true)
          ..addColumns([oxyDatabase.serialNo]))
        .map((row) => row.read(oxyDatabase.serialNo));

    // Execute the query and filter out null values
    List<String?> resultList = await query.get();
    List<String> serialNumbers = resultList
        .where((serialNo) => serialNo != null)
        .cast<String>()
        .toList();

    return serialNumbers;
  }

  Future<void> deleteDataOlderThanThreeMonths() async {
    final DateTime threeMonthsAgo = DateTime.now().subtract(Duration(days: 90));

    // Delete data older than 3 months from OxyDatabase table
    await (delete(oxyDatabase)
          ..where((tbl) => tbl.recordedAt.isSmallerThanValue(threeMonthsAgo)))
        .go();

    // Delete data older than 3 months from LimitSettingsTable
    await (delete(limitSettingsTable)
          ..where((tbl) => tbl.recordedAt.isSmallerThanValue(threeMonthsAgo)))
        .go();

    // Delete data older than 3 months from AlarmTable
    // await (delete(alarmTable)
    //       ..where((tbl) => tbl.recordedAt.isSmallerThanValue(threeMonthsAgo)))
    //     .go();

    print("Data older than 3 months has been deleted from all tables.");
  }

  // Future<void> deleteAllData() async {
  //   await delete(oxyDatabase).go();
  // }
}
