import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiKey =
    '5aca93769d72b27dce1aeb19f3a5926d'; // Ganti dengan API key Anda

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _basecampList = []; // Menyimpan data basecamp
  List<Map<String, dynamic>> _weatherData =
      []; // Menyimpan data cuaca untuk basecamp

  @override
  void initState() {
    super.initState();
    fetchBasecampList(); // Ambil data basecamp dari API
  }

  // Ambil data basecamp dari API
  Future<void> fetchBasecampList() async {
    final url =
        "https://finalpro-api-1013759214686.us-central1.run.app/basecamp";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          // Ambil hanya nama basecamp dan lokasi (latitude, longitude)
          List<Map<String, dynamic>> filteredBasecampList =
              data.map((basecamp) {
                String location =
                    basecamp['location'] ?? ''; // Pastikan location tidak null

                // Periksa apakah location memiliki data yang benar (dua nilai)
                if (location.isNotEmpty) {
                  List<String> coordinates = location.split(',');

                  // Validasi panjang array coordinates harus 2
                  if (coordinates.length == 2) {
                    double latitude =
                        double.tryParse(coordinates[0].trim()) ?? 0.0;
                    double longitude =
                        double.tryParse(coordinates[1].trim()) ?? 0.0;
                    return {
                      'name': basecamp['name'],
                      'latitude': latitude,
                      'longitude': longitude,
                    };
                  } else {
                    // Jika format tidak sesuai, beri nilai default
                    return {
                      'name': basecamp['name'],
                      'latitude': 0.0,
                      'longitude': 0.0,
                    };
                  }
                } else {
                  // Jika location kosong, beri nilai default
                  return {
                    'name': basecamp['name'],
                    'latitude': 0.0,
                    'longitude': 0.0,
                  };
                }
              }).toList();

          // Ambil data cuaca untuk tiap basecamp
          for (var basecamp in filteredBasecampList) {
            // Hanya fetch weather jika koordinat valid
            if ((basecamp['latitude'] as double) != 0.0 &&
                (basecamp['longitude'] as double) != 0.0) {
              await fetchWeatherData(
                basecamp['latitude'],
                basecamp['longitude'],
                basecamp['name'],
              );
            }
          }

          setState(() {
            _basecampList = filteredBasecampList;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid data format from server';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Failed to load basecamp, status code: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching basecamp: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> fetchWeatherData(
    double latitude,
    double longitude,
    String basecampName,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      print('Request URL: $url'); // Log URL request untuk debugging

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          'Response Data: $data',
        ); // Log response untuk memastikan data yang diterima

        // Periksa apakah data cuaca ada dan valid
        if (data != null && data['main'] != null && data['weather'] != null) {
          setState(() {
            _weatherData.add({
              'name': basecampName,
              'temperature': data['main']['temp'],
              'description': data['weather'][0]['description'],
              'icon': data['weather'][0]['icon'],
            });
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid weather data received';
          });
          print(
            'Error: Invalid weather data',
          ); // Log error jika data cuaca invalid
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load weather data. Status code: ${response.statusCode}';
        });
        print(
          'Error: Status Code ${response.statusCode}',
        ); // Log error status code
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching weather data: $e';
      });
      print('Error: $e'); // Log jika ada error saat mengambil data
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather for Basecamps'),
        backgroundColor: Colors.green,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _weatherData.isEmpty
              ? const Center(child: Text('No weather data available'))
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: _weatherData.length,
                itemBuilder: (context, index) {
                  var weather = _weatherData[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.network(
                            'https://openweathermap.org/img/wn/${weather['icon']}@2x.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${weather['temperature']}°C',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                weather['description'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
