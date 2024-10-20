import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  Future<Map<String, dynamic>> fetchWeatherData(
      double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class ApiTest {}
