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

class $LimitSettingsTableTable extends LimitSettingsTable
    with TableInfo<$LimitSettingsTableTable, LimitSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LimitSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _limit_maxMeta =
      const VerificationMeta('limit_max');
  @override
  late final GeneratedColumn<double> limit_max = GeneratedColumn<double>(
      'LimitMax', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _limit_minMeta =
      const VerificationMeta('limit_min');
  @override
  late final GeneratedColumn<double> limit_min = GeneratedColumn<double>(
      'LimitMin', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'Type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      [id, limit_max, limit_min, type, serialNo, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'limit_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<LimitSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('LimitMax')) {
      context.handle(_limit_maxMeta,
          limit_max.isAcceptableOrUnknown(data['LimitMax']!, _limit_maxMeta));
    } else if (isInserting) {
      context.missing(_limit_maxMeta);
    }
    if (data.containsKey('LimitMin')) {
      context.handle(_limit_minMeta,
          limit_min.isAcceptableOrUnknown(data['LimitMin']!, _limit_minMeta));
    } else if (isInserting) {
      context.missing(_limit_minMeta);
    }
    if (data.containsKey('Type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['Type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
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
  LimitSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LimitSettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      limit_max: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}LimitMax'])!,
      limit_min: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}LimitMin'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Type'])!,
      serialNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serialNo'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at']),
    );
  }

  @override
  $LimitSettingsTableTable createAlias(String alias) {
    return $LimitSettingsTableTable(attachedDatabase, alias);
  }
}

class LimitSettingsTableData extends DataClass
    implements Insertable<LimitSettingsTableData> {
  final int id;
  final double limit_max;
  final double limit_min;
  final String type;
  final String serialNo;
  final DateTime? recordedAt;
  const LimitSettingsTableData(
      {required this.id,
      required this.limit_max,
      required this.limit_min,
      required this.type,
      required this.serialNo,
      this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['LimitMax'] = Variable<double>(limit_max);
    map['LimitMin'] = Variable<double>(limit_min);
    map['Type'] = Variable<String>(type);
    map['serialNo'] = Variable<String>(serialNo);
    if (!nullToAbsent || recordedAt != null) {
      map['recorded_at'] = Variable<DateTime>(recordedAt);
    }
    return map;
  }

  LimitSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return LimitSettingsTableCompanion(
      id: Value(id),
      limit_max: Value(limit_max),
      limit_min: Value(limit_min),
      type: Value(type),
      serialNo: Value(serialNo),
      recordedAt: recordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedAt),
    );
  }

  factory LimitSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LimitSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      limit_max: serializer.fromJson<double>(json['limit_max']),
      limit_min: serializer.fromJson<double>(json['limit_min']),
      type: serializer.fromJson<String>(json['type']),
      serialNo: serializer.fromJson<String>(json['serialNo']),
      recordedAt: serializer.fromJson<DateTime?>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'limit_max': serializer.toJson<double>(limit_max),
      'limit_min': serializer.toJson<double>(limit_min),
      'type': serializer.toJson<String>(type),
      'serialNo': serializer.toJson<String>(serialNo),
      'recordedAt': serializer.toJson<DateTime?>(recordedAt),
    };
  }

  LimitSettingsTableData copyWith(
          {int? id,
          double? limit_max,
          double? limit_min,
          String? type,
          String? serialNo,
          Value<DateTime?> recordedAt = const Value.absent()}) =>
      LimitSettingsTableData(
        id: id ?? this.id,
        limit_max: limit_max ?? this.limit_max,
        limit_min: limit_min ?? this.limit_min,
        type: type ?? this.type,
        serialNo: serialNo ?? this.serialNo,
        recordedAt: recordedAt.present ? recordedAt.value : this.recordedAt,
      );
  LimitSettingsTableData copyWithCompanion(LimitSettingsTableCompanion data) {
    return LimitSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      limit_max: data.limit_max.present ? data.limit_max.value : this.limit_max,
      limit_min: data.limit_min.present ? data.limit_min.value : this.limit_min,
      type: data.type.present ? data.type.value : this.type,
      serialNo: data.serialNo.present ? data.serialNo.value : this.serialNo,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LimitSettingsTableData(')
          ..write('id: $id, ')
          ..write('limit_max: $limit_max, ')
          ..write('limit_min: $limit_min, ')
          ..write('type: $type, ')
          ..write('serialNo: $serialNo, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, limit_max, limit_min, type, serialNo, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LimitSettingsTableData &&
          other.id == this.id &&
          other.limit_max == this.limit_max &&
          other.limit_min == this.limit_min &&
          other.type == this.type &&
          other.serialNo == this.serialNo &&
          other.recordedAt == this.recordedAt);
}

class LimitSettingsTableCompanion
    extends UpdateCompanion<LimitSettingsTableData> {
  final Value<int> id;
  final Value<double> limit_max;
  final Value<double> limit_min;
  final Value<String> type;
  final Value<String> serialNo;
  final Value<DateTime?> recordedAt;
  const LimitSettingsTableCompanion({
    this.id = const Value.absent(),
    this.limit_max = const Value.absent(),
    this.limit_min = const Value.absent(),
    this.type = const Value.absent(),
    this.serialNo = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  LimitSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required double limit_max,
    required double limit_min,
    required String type,
    required String serialNo,
    this.recordedAt = const Value.absent(),
  })  : limit_max = Value(limit_max),
        limit_min = Value(limit_min),
        type = Value(type),
        serialNo = Value(serialNo);
  static Insertable<LimitSettingsTableData> custom({
    Expression<int>? id,
    Expression<double>? limit_max,
    Expression<double>? limit_min,
    Expression<String>? type,
    Expression<String>? serialNo,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (limit_max != null) 'LimitMax': limit_max,
      if (limit_min != null) 'LimitMin': limit_min,
      if (type != null) 'Type': type,
      if (serialNo != null) 'serialNo': serialNo,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  LimitSettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<double>? limit_max,
      Value<double>? limit_min,
      Value<String>? type,
      Value<String>? serialNo,
      Value<DateTime?>? recordedAt}) {
    return LimitSettingsTableCompanion(
      id: id ?? this.id,
      limit_max: limit_max ?? this.limit_max,
      limit_min: limit_min ?? this.limit_min,
      type: type ?? this.type,
      serialNo: serialNo ?? this.serialNo,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (limit_max.present) {
      map['LimitMax'] = Variable<double>(limit_max.value);
    }
    if (limit_min.present) {
      map['LimitMin'] = Variable<double>(limit_min.value);
    }
    if (type.present) {
      map['Type'] = Variable<String>(type.value);
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
    return (StringBuffer('LimitSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('limit_max: $limit_max, ')
          ..write('limit_min: $limit_min, ')
          ..write('type: $type, ')
          ..write('serialNo: $serialNo, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $AlarmTableTable extends AlarmTable
    with TableInfo<$AlarmTableTable, AlarmTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'Alarm Value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _limitmaxMeta =
      const VerificationMeta('limitmax');
  @override
  late final GeneratedColumn<double> limitmax = GeneratedColumn<double>(
      'LimitMax', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _limitminMeta =
      const VerificationMeta('limitmin');
  @override
  late final GeneratedColumn<double> limitmin = GeneratedColumn<double>(
      'LimitMin', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'Type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      [id, value, limitmax, limitmin, type, serialNo, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alarm_table';
  @override
  VerificationContext validateIntegrity(Insertable<AlarmTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('Alarm Value')) {
      context.handle(_valueMeta,
          value.isAcceptableOrUnknown(data['Alarm Value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('LimitMax')) {
      context.handle(_limitmaxMeta,
          limitmax.isAcceptableOrUnknown(data['LimitMax']!, _limitmaxMeta));
    } else if (isInserting) {
      context.missing(_limitmaxMeta);
    }
    if (data.containsKey('LimitMin')) {
      context.handle(_limitminMeta,
          limitmin.isAcceptableOrUnknown(data['LimitMin']!, _limitminMeta));
    } else if (isInserting) {
      context.missing(_limitminMeta);
    }
    if (data.containsKey('Type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['Type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
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
  AlarmTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlarmTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}Alarm Value'])!,
      limitmax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}LimitMax'])!,
      limitmin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}LimitMin'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Type'])!,
      serialNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serialNo'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at']),
    );
  }

  @override
  $AlarmTableTable createAlias(String alias) {
    return $AlarmTableTable(attachedDatabase, alias);
  }
}

class AlarmTableData extends DataClass implements Insertable<AlarmTableData> {
  final int id;
  final double value;
  final double limitmax;
  final double limitmin;
  final String type;
  final String serialNo;
  final DateTime? recordedAt;
  const AlarmTableData(
      {required this.id,
      required this.value,
      required this.limitmax,
      required this.limitmin,
      required this.type,
      required this.serialNo,
      this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['Alarm Value'] = Variable<double>(value);
    map['LimitMax'] = Variable<double>(limitmax);
    map['LimitMin'] = Variable<double>(limitmin);
    map['Type'] = Variable<String>(type);
    map['serialNo'] = Variable<String>(serialNo);
    if (!nullToAbsent || recordedAt != null) {
      map['recorded_at'] = Variable<DateTime>(recordedAt);
    }
    return map;
  }

  AlarmTableCompanion toCompanion(bool nullToAbsent) {
    return AlarmTableCompanion(
      id: Value(id),
      value: Value(value),
      limitmax: Value(limitmax),
      limitmin: Value(limitmin),
      type: Value(type),
      serialNo: Value(serialNo),
      recordedAt: recordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedAt),
    );
  }

  factory AlarmTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlarmTableData(
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<double>(json['value']),
      limitmax: serializer.fromJson<double>(json['limitmax']),
      limitmin: serializer.fromJson<double>(json['limitmin']),
      type: serializer.fromJson<String>(json['type']),
      serialNo: serializer.fromJson<String>(json['serialNo']),
      recordedAt: serializer.fromJson<DateTime?>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<double>(value),
      'limitmax': serializer.toJson<double>(limitmax),
      'limitmin': serializer.toJson<double>(limitmin),
      'type': serializer.toJson<String>(type),
      'serialNo': serializer.toJson<String>(serialNo),
      'recordedAt': serializer.toJson<DateTime?>(recordedAt),
    };
  }

  AlarmTableData copyWith(
          {int? id,
          double? value,
          double? limitmax,
          double? limitmin,
          String? type,
          String? serialNo,
          Value<DateTime?> recordedAt = const Value.absent()}) =>
      AlarmTableData(
        id: id ?? this.id,
        value: value ?? this.value,
        limitmax: limitmax ?? this.limitmax,
        limitmin: limitmin ?? this.limitmin,
        type: type ?? this.type,
        serialNo: serialNo ?? this.serialNo,
        recordedAt: recordedAt.present ? recordedAt.value : this.recordedAt,
      );
  AlarmTableData copyWithCompanion(AlarmTableCompanion data) {
    return AlarmTableData(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
      limitmax: data.limitmax.present ? data.limitmax.value : this.limitmax,
      limitmin: data.limitmin.present ? data.limitmin.value : this.limitmin,
      type: data.type.present ? data.type.value : this.type,
      serialNo: data.serialNo.present ? data.serialNo.value : this.serialNo,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlarmTableData(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('limitmax: $limitmax, ')
          ..write('limitmin: $limitmin, ')
          ..write('type: $type, ')
          ..write('serialNo: $serialNo, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, value, limitmax, limitmin, type, serialNo, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlarmTableData &&
          other.id == this.id &&
          other.value == this.value &&
          other.limitmax == this.limitmax &&
          other.limitmin == this.limitmin &&
          other.type == this.type &&
          other.serialNo == this.serialNo &&
          other.recordedAt == this.recordedAt);
}

class AlarmTableCompanion extends UpdateCompanion<AlarmTableData> {
  final Value<int> id;
  final Value<double> value;
  final Value<double> limitmax;
  final Value<double> limitmin;
  final Value<String> type;
  final Value<String> serialNo;
  final Value<DateTime?> recordedAt;
  const AlarmTableCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.limitmax = const Value.absent(),
    this.limitmin = const Value.absent(),
    this.type = const Value.absent(),
    this.serialNo = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  AlarmTableCompanion.insert({
    this.id = const Value.absent(),
    required double value,
    required double limitmax,
    required double limitmin,
    required String type,
    required String serialNo,
    this.recordedAt = const Value.absent(),
  })  : value = Value(value),
        limitmax = Value(limitmax),
        limitmin = Value(limitmin),
        type = Value(type),
        serialNo = Value(serialNo);
  static Insertable<AlarmTableData> custom({
    Expression<int>? id,
    Expression<double>? value,
    Expression<double>? limitmax,
    Expression<double>? limitmin,
    Expression<String>? type,
    Expression<String>? serialNo,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'Alarm Value': value,
      if (limitmax != null) 'LimitMax': limitmax,
      if (limitmin != null) 'LimitMin': limitmin,
      if (type != null) 'Type': type,
      if (serialNo != null) 'serialNo': serialNo,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  AlarmTableCompanion copyWith(
      {Value<int>? id,
      Value<double>? value,
      Value<double>? limitmax,
      Value<double>? limitmin,
      Value<String>? type,
      Value<String>? serialNo,
      Value<DateTime?>? recordedAt}) {
    return AlarmTableCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
      limitmax: limitmax ?? this.limitmax,
      limitmin: limitmin ?? this.limitmin,
      type: type ?? this.type,
      serialNo: serialNo ?? this.serialNo,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['Alarm Value'] = Variable<double>(value.value);
    }
    if (limitmax.present) {
      map['LimitMax'] = Variable<double>(limitmax.value);
    }
    if (limitmin.present) {
      map['LimitMin'] = Variable<double>(limitmin.value);
    }
    if (type.present) {
      map['Type'] = Variable<String>(type.value);
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
    return (StringBuffer('AlarmTableCompanion(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('limitmax: $limitmax, ')
          ..write('limitmin: $limitmin, ')
          ..write('type: $type, ')
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
  late final $LimitSettingsTableTable limitSettingsTable =
      $LimitSettingsTableTable(this);
  late final $AlarmTableTable alarmTable = $AlarmTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [oxyDatabase, limitSettingsTable, alarmTable];
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

typedef $$LimitSettingsTableTableCreateCompanionBuilder
    = LimitSettingsTableCompanion Function({
  Value<int> id,
  required double limit_max,
  required double limit_min,
  required String type,
  required String serialNo,
  Value<DateTime?> recordedAt,
});
typedef $$LimitSettingsTableTableUpdateCompanionBuilder
    = LimitSettingsTableCompanion Function({
  Value<int> id,
  Value<double> limit_max,
  Value<double> limit_min,
  Value<String> type,
  Value<String> serialNo,
  Value<DateTime?> recordedAt,
});

class $$LimitSettingsTableTableTableManager extends RootTableManager<
    _$AppDb,
    $LimitSettingsTableTable,
    LimitSettingsTableData,
    $$LimitSettingsTableTableFilterComposer,
    $$LimitSettingsTableTableOrderingComposer,
    $$LimitSettingsTableTableCreateCompanionBuilder,
    $$LimitSettingsTableTableUpdateCompanionBuilder> {
  $$LimitSettingsTableTableTableManager(
      _$AppDb db, $LimitSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LimitSettingsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$LimitSettingsTableTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> limit_max = const Value.absent(),
            Value<double> limit_min = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> serialNo = const Value.absent(),
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              LimitSettingsTableCompanion(
            id: id,
            limit_max: limit_max,
            limit_min: limit_min,
            type: type,
            serialNo: serialNo,
            recordedAt: recordedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double limit_max,
            required double limit_min,
            required String type,
            required String serialNo,
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              LimitSettingsTableCompanion.insert(
            id: id,
            limit_max: limit_max,
            limit_min: limit_min,
            type: type,
            serialNo: serialNo,
            recordedAt: recordedAt,
          ),
        ));
}

class $$LimitSettingsTableTableFilterComposer
    extends FilterComposer<_$AppDb, $LimitSettingsTableTable> {
  $$LimitSettingsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get limit_max => $state.composableBuilder(
      column: $state.table.limit_max,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get limit_min => $state.composableBuilder(
      column: $state.table.limit_min,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
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

class $$LimitSettingsTableTableOrderingComposer
    extends OrderingComposer<_$AppDb, $LimitSettingsTableTable> {
  $$LimitSettingsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get limit_max => $state.composableBuilder(
      column: $state.table.limit_max,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get limit_min => $state.composableBuilder(
      column: $state.table.limit_min,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
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

typedef $$AlarmTableTableCreateCompanionBuilder = AlarmTableCompanion Function({
  Value<int> id,
  required double value,
  required double limitmax,
  required double limitmin,
  required String type,
  required String serialNo,
  Value<DateTime?> recordedAt,
});
typedef $$AlarmTableTableUpdateCompanionBuilder = AlarmTableCompanion Function({
  Value<int> id,
  Value<double> value,
  Value<double> limitmax,
  Value<double> limitmin,
  Value<String> type,
  Value<String> serialNo,
  Value<DateTime?> recordedAt,
});

class $$AlarmTableTableTableManager extends RootTableManager<
    _$AppDb,
    $AlarmTableTable,
    AlarmTableData,
    $$AlarmTableTableFilterComposer,
    $$AlarmTableTableOrderingComposer,
    $$AlarmTableTableCreateCompanionBuilder,
    $$AlarmTableTableUpdateCompanionBuilder> {
  $$AlarmTableTableTableManager(_$AppDb db, $AlarmTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AlarmTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AlarmTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<double> limitmax = const Value.absent(),
            Value<double> limitmin = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> serialNo = const Value.absent(),
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              AlarmTableCompanion(
            id: id,
            value: value,
            limitmax: limitmax,
            limitmin: limitmin,
            type: type,
            serialNo: serialNo,
            recordedAt: recordedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double value,
            required double limitmax,
            required double limitmin,
            required String type,
            required String serialNo,
            Value<DateTime?> recordedAt = const Value.absent(),
          }) =>
              AlarmTableCompanion.insert(
            id: id,
            value: value,
            limitmax: limitmax,
            limitmin: limitmin,
            type: type,
            serialNo: serialNo,
            recordedAt: recordedAt,
          ),
        ));
}

class $$AlarmTableTableFilterComposer
    extends FilterComposer<_$AppDb, $AlarmTableTable> {
  $$AlarmTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get limitmax => $state.composableBuilder(
      column: $state.table.limitmax,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get limitmin => $state.composableBuilder(
      column: $state.table.limitmin,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
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

class $$AlarmTableTableOrderingComposer
    extends OrderingComposer<_$AppDb, $AlarmTableTable> {
  $$AlarmTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get limitmax => $state.composableBuilder(
      column: $state.table.limitmax,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get limitmin => $state.composableBuilder(
      column: $state.table.limitmin,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
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
  $$LimitSettingsTableTableTableManager get limitSettingsTable =>
      $$LimitSettingsTableTableTableManager(_db, _db.limitSettingsTable);
  $$AlarmTableTableTableManager get alarmTable =>
      $$AlarmTableTableTableManager(_db, _db.alarmTable);
}
