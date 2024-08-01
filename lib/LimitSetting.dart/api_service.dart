// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'min_max_data.dart';

class ApiService {
  static Future<MinMaxData> fetchMinMaxData() async {
    final response =
        await http.get(Uri.parse('http://192.168.4.1/getminmaxdata'));

    if (response.statusCode == 200) {
      return MinMaxData.fromJson(jsonDecode(response.body)[0]);
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<void> postMinMaxData(MinMaxData data) async {
    final response = await http.post(
      Uri.parse('http://192.168.4.1/postminmaxdata'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data.toJson()),
    );
    print("Response Body --> ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to post data');
    }
  }
}

Future<MinMaxData> retrieveData() async {
  final prefs = await SharedPreferences.getInstance();

  double purityMax = prefs.getDouble('purityMax') ?? 0.0;
  double purityMin = prefs.getDouble('purityMin') ?? 0.0;
  double flowMax = prefs.getDouble('flowMax') ?? 0.0;
  double flowMin = prefs.getDouble('flowMin') ?? 0.0;
  double pressureMax = prefs.getDouble('pressureMax') ?? 0.0;
  double pressureMin = prefs.getDouble('pressureMin') ?? 0.0;
  double tempMax = prefs.getDouble('tempMax') ?? 0.0;
  double tempMin = prefs.getDouble('tempMin') ?? 0.0;
  String serialNo = prefs.getString('serialNo') ?? "";
  String locationName = prefs.getString('locationName') ?? "";

  return MinMaxData(
    o2Max: ((purityMax * 10).round()).toString(),
    o2Min: ((purityMin * 10).round()).toString(),
    flowMax: ((flowMax * 10).round()).toString(),
    flowMin: ((flowMin * 10).round()).toString(),
    pressureMax: ((pressureMax * 10).round()).toString(),
    pressureMin: ((pressureMin * 10).round()).toString(),
    temperatureMax: ((tempMax * 10).round()).toString(),
    temperatureMin: ((tempMin * 10).round()).toString(),
    serialNo: serialNo,
    locationName: locationName,
  );
}

Future<void> postStoredData() async {
  print("postdata");
  try {
    MinMaxData data = await retrieveData();
    print("Dataaa: $data");
    await ApiService.postMinMaxData(data);
    print('Data posted successfully');
  } catch (e) {
    print('Failed to post data: $e');
    rethrow;
  }
}
