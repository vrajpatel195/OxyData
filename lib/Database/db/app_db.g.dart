// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $OxyDatabaseTable extends OxyDatabase
    with TableInfo<$OxyDatabaseTable, OxyDatabaseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OxyDatabaseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<BigInt> id = GeneratedColumn<BigInt>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.bigInt,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _purityMeta = const VerificationMeta('purity');
  @override
  late final GeneratedColumn<double> purity = GeneratedColumn<double>(
      'purity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _flowMeta = const VerificationMeta('flow');
  @override
  late final GeneratedColumn<double> flow = GeneratedColumn<double>(
      'flow', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _pressureMeta =
      const VerificationMeta('pressure');
  @override
  late final GeneratedColumn<double> pressure = GeneratedColumn<double>(
      'pressure', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tempMeta = const VerificationMeta('temp');
  @override
  late final GeneratedColumn<double> temp = GeneratedColumn<double>(
      'temp', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _serialNoMeta =
      const VerificationMeta('serialNo');
  @override
  late final GeneratedColumn<String> serialNo = GeneratedColumn<String>(
      'serialNo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, purity, flow, pressure, temp, serialNo, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'oxy_database';
  @override
  VerificationContext validateIntegrity(Insertable<OxyDatabaseData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('purity')) {
      context.handle(_purityMeta,
          purity.isAcceptableOrUnknown(data['purity']!, _purityMeta));
    } else if (isInserting) {
      context.missing(_purityMeta);
    }
    if (data.containsKey('flow')) {
      context.handle(
          _flowMeta, flow.isAcceptableOrUnknown(data['flow']!, _flowMeta));
    } else if (isInserting) {
      context.missing(_flowMeta);
    }
    if (data.containsKey('pressure')) {
      context.handle(_pressureMeta,
          pressure.isAcceptableOrUnknown(data['pressure']!, _pressureMeta));
    } else if (isInserting) {
      context.missing(_pressureMeta);
    }
    if (data.containsKey('temp')) {
      context.handle(
          _tempMeta, temp.isAcceptableOrUnknown(data['temp']!, _tempMeta));
    } else if (isInserting) {
      context.missing(_tempMeta);
    }
    if (data.containsKey('serialNo')) {
      context.handle(_serialNoMeta,
          serialNo.isAcceptableOrUnknown(data['serialNo']!, _serialNoMeta));
    } else if (isInserting) {
      context.missing(_serialNoMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OxyDatabaseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OxyDatabaseData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id'])!,
      purity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purity'])!,
      flow: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}flow'])!,
      pressure: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pressure'])!,
      temp: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temp'])!,
      serialNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serialNo'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at']),
    );
  }

  @override
  $OxyDatabaseTable createAlias(String alias) {
    return $OxyDatabaseTable(attachedDatabase, alias);
  }
}

class OxyDatabaseData extends DataClass implements Insertable<OxyDatabaseData> {
  final BigInt id;
  final double purity;
  final double flow;
  final double pressure;
  final double temp;
  final String serialNo;
  final DateTime? recordedAt;
  const OxyDatabaseData(
      {required this.id,
      required this.purity,
      required this.flow,
      required this.pressure,
      required this.temp,
      required this.serialNo,
      this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<BigInt>(id);
    map['purity'] = Variable<double>(purity);
    map['flow'] = Variable<double>(flow);
    map['pressure'] = Variable<double>(pressure);
    map['temp'] = Variable<double>(temp);
    map['serialNo'] = Variable<String>(serialNo);
    if (!nullToAbsent || recordedAt != null) {
      map['recorded_at'] = Variable<DateTime>(recordedAt);
    }
    return map;
  }

  OxyDatabaseCompanion toCompanion(bool nullToAbsent) {
    return OxyDatabaseCompanion(
      id: Value(id),
      purity: Value(purity),
      flow: Value(flow),
      pressure: Value(pressure),
      temp: Value(temp),
      serialNo: Value(serialNo),
      recordedAt: recordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedAt),
    );
  }

  factory OxyDatabaseData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OxyDatabaseData(
      id: serializer.fromJson<BigInt>(json['id']),
      purity: serializer.fromJson<double>(json['purity']),
      flow: serializer.fromJson<double>(json['flow']),
      pressure: serializer.fromJson<double>(json['pressure']),
      temp: serializer.fromJson<double>(json['temp']),
      serialNo: serializer.fromJson<String>(json['serialNo']),
      recordedAt: serializer.fromJson<DateTime?>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<BigInt>(id),
      'purity': serializer.toJson<double>(purity),
      'flow': serializer.toJson<double>(flow),
      'pressure': serializer.toJson<double>(pressure),
      'temp': serializer.toJson<double>(temp),
      'serialNo': serializer.toJson<String>(serialNo),
      'recordedAt': serializer.toJson<DateTime?>(recordedAt),
    };
  }

  OxyDatabaseData copyWith(
          {BigInt? id,
          double? purity,
          double? flow,
          double? pressure,
          double? temp,
          String? serialNo,
          Value<DateTime?> recordedAt = const Value.absent()}) =>
      OxyDatabaseData(
        id: id ?? this.id,
        purity: purity ?? this.purity,
        flow: flow ?? this.flow,
        pressure: pressure ?? this.pressure,
        temp: temp ?? this.temp,
        serialNo: serialNo ?? this.serialNo,
        recordedAt: recordedAt.present ? recordedAt.value : this.recordedAt,
      );
  OxyDatabaseData copyWithCompanion(OxyDatabaseCompanion data) {
    return OxyDatabaseData(
      id: data.id.present ? data.id.value : this.id,
      purity: data.purity.present ? data.purity.value : this.purity,
      flow: data.flow.present ? data.flow.value : this.flow,
      pressure: data.pressure.present ? data.pressure.value : this.pressure,
      temp: data.temp.present ? data.temp.value : this.temp,
      serialNo: data.serialNo.present ? data.serialNo.value : this.serialNo,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OxyDatabaseData(')
          ..write('id: $id, ')
          ..write('purity: $purity, ')
          ..write('flow: $flow, ')
          ..write('pressure: $pressure, ')
          ..write('temp: $temp, ')
          ..write('serialNo: $serialNo, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, purity, flow, pressure, temp, serialNo, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OxyDatabaseData &&
          other.id == this.id &&
          other.purity == this.purity &&
          other.flow == this.flow &&
          other.pressure == this.pressure &&
          other.temp == this.temp &&
          other.serialNo == this.serialNo &&
          other.recordedAt == this.recordedAt);
}

class OxyDatabaseCompanion extends UpdateCompanion<OxyDatabaseData> {
  final Value<BigInt> id;
  final Value<double> purity;
  final Value<double> flow;
  final Value<double> pressure;
  final Value<double> temp;
  final Value<String> serialNo;
  final Value<DateTime?> recordedAt;
  const OxyDatabaseCompanion({
    this.id = const Value.absent(),
    this.purity = const Value.absent(),
    this.flow = const Value.absent(),
    this.pressure = const Value.absent(),
    this.temp = const Value.absent(),
    this.serialNo = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  OxyDatabaseCompanion.insert({
    this.id = const Value.absent(),
    required double purity,
    required double flow,
    required double pressure,
    required double temp,
    required String serialNo,
    this.recordedAt = const Value.absent(),
  })  : purity = Value(purity),
        flow = Value(flow),
        pressure = Value(pressure),
        temp = Value(temp),
        serialNo = Value(serialNo);
  static Insertable<OxyDatabaseData> custom({
    Expression<BigInt>? id,
    Expression<double>? purity,
    Expression<double>? flow,
    Expression<double>? pressure,
    Expression<double>? temp,
    Expression<String>? serialNo,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purity != null) 'purity': purity,
      if (flow != null) 'flow': flow,
      if (pressure != null) 'pressure': pressure,
      if (temp != null) 'temp': temp,
      if (serialNo != null) 'serialNo': serialNo,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  OxyDatabaseCompanion copyWith(
      {Value<BigInt>? id,
      Value<double>? purity,
      Value<double>? flow,
      Value<double>? pressure,
      Value<double>? temp,
      Value<String>? serialNo,
      Value<DateTime?>? recordedAt}) {
    return OxyDatabaseCompanion(
      id: id ?? this.id,
      purity: purity ?? this.purity,
      flow: flow ?? this.flow,
      pressure: pressure ?? this.pressure,
      temp: temp ?? this.temp,
      serialNo: serialNo ?? this.serialNo,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<BigInt>(id.value);
    }
    if (purity.present) {
      map['purity'] = Variable<double>(purity.value);
    }
    if (flow.present) {
      map['flow'] = Variable<double>(flow.value);
    }
    if (pressure.present) {
      map['pressure'] = Variable<double>(pressure.value);
    }
    if (temp.present) {
      map['temp'] = Variable<double>(temp.value);
    }
    if (serialNo.present) {
      map['serialNo'] = Variable<String>(serialNo.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OxyDatabaseCompanion(')
          ..write('id: $id, ')
          ..write('purity: $purity, ')
          ..write('flow: $flow, ')
          ..write('pressure: $pressure, ')
          ..write('temp: $temp, ')
          ..write('serialNo: $serialNo, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $OxyDatabaseTable oxyDatabase = $OxyDatabaseTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [oxyDatabase];
}

typedef $$OxyDatabaseTableCreateCompanionBuilder = OxyDatabaseCompanion
    Function({
  Value<BigInt> id,
  required double purity,
  required double flow,
  required double pressure,
  required double temp,
  required String serialNo,
  Value<DateTime?> recordedAt,
});
typedef $$OxyDatabaseTableUpdateCompanionBuilder = OxyDatabaseCompanion
    Function({
  Value<BigInt> id,
  Value<double> purity,
  Value<double> flow,
  Value<double> pressure,
  Value<double> temp,
  Value<String> serialNo,
  Value<DateTime?> recordedAt,
});

class $$OxyDatabaseTableTableManager extends RootTableManager<
    _$AppDb,
    $OxyDatabaseTable,
    OxyDatabaseData,
    $$OxyDatabaseTableFilterComposer,
    $$OxyDatabaseTableOrderingComposer,
    $$OxyDatabaseTableCreateCompanionBuilder,
    $$OxyDatabaseTableUpdateCompanionBuilder> {
  $$OxyDatabaseTableTableManager(_$AppDb db, $OxyDatabaseTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OxyDatabaseTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OxyDatabaseTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<BigInt> id = const Value.absent(),
            Value<double> purity = const Value.absent(),
            Value<double> flow = const Value.absent(),
            Value<double> pressure = const Value.absent(),
            Value<double> temp = const Value.absent(),
            Value<String> serialNo = const Value.absent(),
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              OxyDatabaseCompanion(
            id: id,
            purity: purity,
            flow: flow,
            pressure: pressure,
            temp: temp,
            serialNo: serialNo,
            recordedAt: recordedAt,
          ),
          createCompanionCallback: ({
            Value<BigInt> id = const Value.absent(),
            required double purity,
            required double flow,
            required double pressure,
            required double temp,
            required String serialNo,
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              OxyDatabaseCompanion.insert(
            id: id,
            purity: purity,
            flow: flow,
            pressure: pressure,
            temp: temp,
            serialNo: serialNo,
            recordedAt: recordedAt,
          ),
        ));
}

class $$OxyDatabaseTableFilterComposer
    extends FilterComposer<_$AppDb, $OxyDatabaseTable> {
  $$OxyDatabaseTableFilterComposer(super.$state);
  ColumnFilters<BigInt> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get purity => $state.composableBuilder(
      column: $state.table.purity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get flow => $state.composableBuilder(
      column: $state.table.flow,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get pressure => $state.composableBuilder(
      column: $state.table.pressure,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get temp => $state.composableBuilder(
      column: $state.table.temp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get serialNo => $state.composableBuilder(
      column: $state.table.serialNo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OxyDatabaseTableOrderingComposer
    extends OrderingComposer<_$AppDb, $OxyDatabaseTable> {
  $$OxyDatabaseTableOrderingComposer(super.$state);
  ColumnOrderings<BigInt> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get purity => $state.composableBuilder(
      column: $state.table.purity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get flow => $state.composableBuilder(
      column: $state.table.flow,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get pressure => $state.composableBuilder(
      column: $state.table.pressure,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get temp => $state.composableBuilder(
      column: $state.table.temp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get serialNo => $state.composableBuilder(
      column: $state.table.serialNo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$OxyDatabaseTableTableManager get oxyDatabase =>
      $$OxyDatabaseTableTableManager(_db, _db.oxyDatabase);
}
