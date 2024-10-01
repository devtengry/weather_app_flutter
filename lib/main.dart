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
        primarySwatch: Colors.blue,
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      fetchWeatherData(position.latitude, position.longitude);
    });
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temperature = data['current_weather']['temperature'].toString();
        weatherDescription = data['current_weather']['weathercode'].toString();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load weather data');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servislerinin açık olup olmadığını kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Konum izni iste
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

    // Konumu al
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _determinePosition().then((position) {
                fetchWeatherData(position.latitude, position.longitude);
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Current Location',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  'Temperature: $temperature°C',
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Weather Code: $weatherDescription',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
