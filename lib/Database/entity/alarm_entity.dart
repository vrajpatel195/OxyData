import 'package:drift/drift.dart';

// Define the LimitSettings table
class AlarmTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get value => real().named('Alarm Value')();
  RealColumn get limitmax => real().named('LimitMax')();
  RealColumn get limitmin => real().named('LimitMin')();

  TextColumn get type => text().named('Type')();

  TextColumn get serialNo => text().named('serialNo')();
  DateTimeColumn get recordedAt => dateTime().nullable().named('recorded_at')();
}
