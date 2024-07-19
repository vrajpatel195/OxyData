import 'package:drift/drift.dart';

class OxyDatabase extends Table {
  Column<BigInt> get id => int64().autoIncrement()();

  RealColumn get purity => real().named('purity')();
  RealColumn get flow => real().named('flow')();
  RealColumn get pressure => real().named('pressure')();
  RealColumn get temp => real().named('temp')();
  TextColumn get serialNo => text().named('serialNo')();
  DateTimeColumn get recordedAt => dateTime().nullable()();
}
