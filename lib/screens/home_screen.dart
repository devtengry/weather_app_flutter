import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = "Loading...";
  String temperature = "";
  String weatherDescription = "";
  String windSpeed = "";
  String humidity = "-";
  bool isLoading = true;

  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      fetchCityName(position.latitude, position.longitude);
      fetchWeatherData(position.latitude, position.longitude);
    });
  }

  Future<void> fetchCityName(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=10');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        city = data['address']['city'] ??
            data['address']['town'] ??
            "Unknown location";
      });
    } else {
      setState(() {
        city = "Unknown location";
      });
    }
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    try {
      final data = await _weatherService.fetchWeatherData(latitude, longitude);
      setState(() {
        temperature = data['current_weather']['temperature'].toString();
        windSpeed = data['current_weather']['windspeed'].toString();
        humidity = data['current_weather']['relativehumidity']?.toString() ??
            "-"; // null kontrolü
        weatherDescription = _mapWeatherCodeToDescription(
            data['current_weather']['weathercode']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load weather data');
    }
  }

  String _mapWeatherCodeToDescription(int code) {
    switch (code) {
      case 0:
        return "Clear Sky";
      case 1:
        return "Mainly Clear";
      case 2:
        return "Partly Cloudy";
      case 3:
        return "Overcast";
      case 45:
        return "Foggy";
      case 48:
        return "Depositing Rime Fog";
      case 51:
        return "Drizzle: Light";
      case 53:
        return "Drizzle: Moderate";
      case 55:
        return "Drizzle: Dense";
      case 61:
        return "Rain: Slight";
      case 63:
        return "Rain: Moderate";
      case 65:
        return "Rain: Heavy";
      case 80:
        return "Rain Showers: Slight";
      case 81:
        return "Rain Showers: Moderate";
      case 82:
        return "Rain Showers: Violent";
      case 95:
        return "Thunderstorm: Slight";
      case 96:
        return "Thunderstorm: Moderate";
      default:
        return "Unknown Weather";
    }
  }

  Future<Position> _determinePosition() async {
    return await _locationService.determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 156, 211, 255),
              Color.fromARGB(255, 28, 153, 255),
              Color.fromARGB(255, 69, 0, 166)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        city.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(221, 37, 37, 37),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        weatherDescription,
                        style: const TextStyle(
                            fontSize: 24, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                      // Weather info cards
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: WeatherCard(
                                    icon: Icons.thermostat_rounded,
                                    label: 'Temp',
                                    value: '$temperature°C',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: WeatherCard(
                                    icon: Icons.cloud_rounded,
                                    label: 'Condition',
                                    value: weatherDescription,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: WeatherCard(
                                    icon: Icons.air_rounded,
                                    label: 'Wind',
                                    value: '$windSpeed km/h',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: WeatherCard(
                                    icon: Icons.opacity_rounded,
                                    label: 'Humidity',
                                    value:
                                        '$humidity%', // Null kontrolü yapılmış değer
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          _determinePosition().then((position) {
            fetchCityName(position.latitude, position.longitude);
            fetchWeatherData(position.latitude, position.longitude);
          });
        },
        backgroundColor: const Color.fromARGB(168, 42, 42, 42),
        child: const Icon(
          Icons.refresh,
          color: Color.fromARGB(164, 255, 255, 255),
        ),
      ),
    );
  }
}
