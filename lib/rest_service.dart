import 'home_screen.dart';
import 'package:http/http.dart' as http;


class RestService {
  Future<http.Response> fetchWeatherData() {
    return http.get(Uri.parse('http://api.weatherapi.com/v1'));
  }
}