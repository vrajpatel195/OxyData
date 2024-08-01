import 'package:drift/drift.dart';

class LimitSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get limit_max => real().named('LimitMax')();
  RealColumn get limit_min => real().named('LimitMin')();

  TextColumn get type => text().named('Type')();

  TextColumn get serialNo => text().named('serialNo')();
  DateTimeColumn get recordedAt => dateTime().nullable().named('recorded_at')();
}
