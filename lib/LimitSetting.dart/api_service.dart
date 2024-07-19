// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
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
