// lib/min_max_data.dart
class MinMaxData {
  String o2Min;
  String o2Max;
  String flowMin;
  String flowMax;
  String temperatureMin;
  String temperatureMax;
  String pressureMin;
  String pressureMax;
  String serialNo;
  String locationName;

  MinMaxData({
    required this.o2Min,
    required this.o2Max,
    required this.flowMin,
    required this.flowMax,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.pressureMin,
    required this.pressureMax,
    required this.serialNo,
    required this.locationName,
  });

  factory MinMaxData.fromJson(Map<String, dynamic> json) {
    return MinMaxData(
      o2Min: json['o2_min'],
      o2Max: json['o2_max'],
      flowMin: json['flow_min'],
      flowMax: json['flow_max'],
      temperatureMin: json['temperature_min'],
      temperatureMax: json['temperature_max'],
      pressureMin: json['pressure_min'],
      pressureMax: json['pressure_max'],
      serialNo: json['serialNo'],
      locationName: json['locationName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'o2_min': o2Min,
      'o2_max': o2Max,
      'flow_min': flowMin,
      'flow_max': flowMax,
      'temperature_min': temperatureMin,
      'temperature_max': temperatureMax,
      'pressure_min': pressureMin,
      'pressure_max': pressureMax,
    };
  }
}
