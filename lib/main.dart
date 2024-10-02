import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

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
  String humidity = "-"; // Başlangıç değeri "-"
  bool isLoading = true;

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
        city = data['address']['city'] ?? data['address']['town'] ?? "Unknown location";
      });
    } else {
      setState(() {
        city = "Unknown location";
      });
    }
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temperature = data['current_weather']['temperature'].toString();
        windSpeed = data['current_weather']['windspeed'].toString();
        humidity = data['current_weather']['relativehumidity'] != null
            ? data['current_weather']['relativehumidity'].toString()
            : "-"; // humidity değeri null ise "-"
        weatherDescription = _mapWeatherCodeToDescription(data['current_weather']['weathercode']);
        isLoading = false;
      });
    } else {
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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 156, 211, 255), Color.fromARGB(255, 28, 153, 255), Color.fromARGB(255, 69, 0, 166)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        constraints: BoxConstraints.expand(),
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
                        style: const TextStyle(fontSize: 24, color: Colors.black54),
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
                                    value: '$humidity%', // Null kontrolü yapılmış değer
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
        child: const Icon(Icons.refresh, color: Color.fromARGB(164, 255, 255, 255),),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color.fromARGB(164, 34, 34, 34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color.fromARGB(210, 229, 229, 229),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(164, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(205, 255, 255, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
