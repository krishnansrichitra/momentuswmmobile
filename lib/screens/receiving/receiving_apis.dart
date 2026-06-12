import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_config.dart';

class ReceivingApiService {
  static Future<List<String>> getInitScreen(String selectedOption) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString("jwt");

    final uri = Uri.parse(
        "${AppConfig.apiBaseUrl}/wms/rcvcontroller/templateScreen"
    ).replace(
      queryParameters: {
        "option": selectedOption,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }

    throw Exception("Failed to load data");
  }
}