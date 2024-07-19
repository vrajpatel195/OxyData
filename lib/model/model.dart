class OxyData {
  String? purity;
  String? flowRate;
  String? pressure;
  String? temperature;
  String? serialNo;

  OxyData(
      {this.purity,
      this.flowRate,
      this.pressure,
      this.temperature,
      this.serialNo});

  OxyData.fromJson(Map<String, dynamic> json) {
    purity = json['Purity'];
    flowRate = json['Flow_Rate'];
    pressure = json['Pressure'];
    temperature = json['Temperature'];
    serialNo = json['serialNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Purity'] = this.purity;
    data['Flow_Rate'] = this.flowRate;
    data['Pressure'] = this.pressure;
    data['Temperature'] = this.temperature;
    data['serialNo'] = this.serialNo;
    return data;
  }
}
