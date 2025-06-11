import 'dart:convert'; // Untuk melakukan decoding data JSON
import 'package:flutter/material.dart'; // Menggunakan Flutter untuk UI
import 'package:http/http.dart'
    as http; // Mengimpor HTTP untuk melakukan request API

const String apiKey =
    '5aca93769d72b27dce1aeb19f3a5926d'; // API key untuk akses OpenWeatherMap

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool _isLoading = true; // Menyimpan status loading
  String? _errorMessage; // Menyimpan pesan error jika terjadi kesalahan
  List<Map<String, dynamic>> _basecampList = []; // Menyimpan daftar basecamp
  List<Map<String, dynamic>> _weatherData =
      []; // Menyimpan data cuaca untuk setiap basecamp

  @override
  void initState() {
    super.initState();
    fetchBasecampList(); // Ambil data basecamp ketika halaman dimuat
  }

  // Fungsi untuk mengambil data basecamp dari API
  Future<void> fetchBasecampList() async {
    const url =
        "https://finalpro-api-1013759214686.us-central1.run.app/basecamp"; // URL untuk API basecamp

    try {
      print('Fetching basecamp data from: $url');
      final response = await http.get(
        Uri.parse(url),
      ); // Melakukan HTTP GET request
      print('Basecamp API Response Status: ${response.statusCode}');
      print('Basecamp API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Jika response status 200 OK
        final data = jsonDecode(response.body); // Parsing response JSON

        if (data is List && data.isNotEmpty) {
          List<Map<String, dynamic>> filteredBasecampList =
              []; // Daftar basecamp yang valid

          for (var basecamp in data) {
            String location =
                basecamp['location']?.toString() ?? ''; // Lokasi basecamp
            String name =
                basecamp['name']?.toString() ??
                'Unknown Basecamp'; // Nama basecamp

            print('Processing basecamp: $name, location: $location');

            if (location.isNotEmpty) {
              List<String> coordinates;

              // Memeriksa apakah koordinat dipisahkan oleh koma atau spasi
              if (location.contains(',')) {
                coordinates = location.split(','); // Pisahkan dengan koma
              } else if (location.contains(' ')) {
                coordinates = location.split(' '); // Pisahkan dengan spasi
              } else {
                print('Unknown coordinate format for $name: $location');
                continue; // Skip basecamp dengan format lokasi yang tidak dikenali
              }

              if (coordinates.length >= 2) {
                double? latitude = double.tryParse(
                  coordinates[0].trim(),
                ); // Latitude
                double? longitude = double.tryParse(
                  coordinates[1].trim(),
                ); // Longitude

                // Validasi apakah koordinat valid
                if (latitude != null &&
                    longitude != null &&
                    latitude != 0.0 &&
                    longitude != 0.0) {
                  filteredBasecampList.add({
                    'name': name,
                    'latitude': latitude,
                    'longitude': longitude,
                  });
                  print('Added valid basecamp: $name ($latitude, $longitude)');
                } else {
                  print('Invalid coordinates for $name: $latitude, $longitude');
                }
              } else {
                print('Invalid coordinate format for $name: $location');
              }
            } else {
              print('Empty location for $name');
            }
          }

          setState(() {
            _basecampList = filteredBasecampList; // Simpan basecamp yang valid
          });

          print('Total valid basecamps: ${filteredBasecampList.length}');

          // Fetch weather data untuk setiap basecamp yang valid
          if (filteredBasecampList.isNotEmpty) {
            await fetchAllWeatherData(
              filteredBasecampList,
            ); // Ambil data cuaca untuk setiap basecamp
          } else {
            setState(() {
              _errorMessage = 'No valid basecamp coordinates found';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'No basecamp data available or invalid format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Failed to load basecamp data. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching basecamp data: $e');
      setState(() {
        _errorMessage = "Error fetching basecamp data: $e";
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengambil data cuaca untuk setiap basecamp
  Future<void> fetchAllWeatherData(List<Map<String, dynamic>> basecamps) async {
    List<Map<String, dynamic>> weatherResults =
        []; // Menyimpan hasil data cuaca

    for (var basecamp in basecamps) {
      try {
        var weatherData = await fetchWeatherData(
          basecamp['latitude'],
          basecamp['longitude'],
          basecamp['name'],
        );

        if (weatherData != null) {
          weatherResults.add(weatherData); // Menambahkan data cuaca ke hasil
        }
      } catch (e) {
        print('Error fetching weather for ${basecamp['name']}: $e');
      }
    }

    setState(() {
      _weatherData = weatherResults; // Simpan hasil data cuaca
      _isLoading = false;
      if (weatherResults.isEmpty) {
        _errorMessage = 'Failed to fetch weather data for any basecamp';
      }
    });
  }

  // Fungsi untuk mengambil data cuaca berdasarkan koordinat latitude dan longitude
  Future<Map<String, dynamic>?> fetchWeatherData(
    double latitude,
    double longitude,
    String basecampName,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric'; // URL API OpenWeatherMap

    try {
      print('Fetching weather for $basecampName: $url');
      final response = await http.get(
        Uri.parse(url),
      ); // Melakukan HTTP GET request untuk cuaca
      print(
        'Weather API Response Status for $basecampName: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Jika status code 200 (OK)
        final data = jsonDecode(response.body); // Parsing response JSON
        print(
          'Weather data received for $basecampName: ${data.toString().substring(0, 100)}...',
        );

        // Validasi data cuaca
        if (data['main'] != null &&
            data['weather'] != null &&
            data['weather'].isNotEmpty) {
          return {
            'name': basecampName,
            'temperature': (data['main']['temp'] as num).toDouble(),
            'description':
                data['weather'][0]['description'] ?? 'No description',
            'icon': data['weather'][0]['icon'] ?? '01d',
            'humidity': data['main']['humidity'] ?? 0,
            'feels_like':
                (data['main']['feels_like'] as num?)?.toDouble() ?? 0.0,
          };
        } else {
          print('Invalid weather data structure for $basecampName');
          return null;
        }
      } else if (response.statusCode == 401) {
        // API key invalid
        print('Invalid API Key for weather service');
        throw Exception(
          'Invalid API Key. Please check your OpenWeatherMap API key.',
        );
      } else {
        print(
          'Weather API error for $basecampName: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Exception fetching weather for $basecampName: $e');
      rethrow; // Melempar error jika terjadi kesalahan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather for Basecamps'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(), // Menampilkan loading spinner
                    SizedBox(height: 16),
                    Text('Loading weather data...'),
                  ],
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline, // Ikon error
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                            _weatherData.clear();
                            _basecampList.clear();
                          });
                          fetchBasecampList(); // Mengulang proses fetch
                        },
                        child: const Text('Retry'), // Tombol retry
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : _weatherData.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: Colors.grey[400],
                    ), // Ikon tidak ada data cuaca
                    const SizedBox(height: 16),
                    const Text(
                      'No Weather Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weather data is not available for any basecamp',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                          _weatherData.clear();
                          _basecampList.clear();
                        });
                        fetchBasecampList(); // Mengulang proses fetch
                      },
                      child: const Text('Refresh'), // Tombol refresh
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                    _weatherData.clear();
                    _basecampList.clear();
                  });
                  await fetchBasecampList(); // Mengulang proses fetch saat di-refresh
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      _weatherData.length, // Jumlah item cuaca yang ditampilkan
                  itemBuilder: (context, index) {
                    var weather = _weatherData[index]; // Ambil data cuaca
                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.network(
                                'https://openweathermap.org/img/wn/${weather['icon']}@2x.png', // Ikon cuaca
                                width: 54,
                                height: 54,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.cloud,
                                    size: 30,
                                    color: Colors.blue,
                                  ); // Ikon default jika gambar gagal
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weather['name'] ??
                                        'Unknown', // Nama basecamp
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.thermostat,
                                        color: Colors.blue[400],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${weather['temperature']?.toStringAsFixed(1) ?? '0'}°C', // Suhu
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    weather['description'] ??
                                        'No description', // Deskripsi cuaca
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  if (weather['feels_like'] != null)
                                    Text(
                                      'Feels like ${weather['feels_like']?.toStringAsFixed(1)}°C', // Suhu terasa
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (weather['humidity'] != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      color: Colors.blue,
                                      size: 22,
                                    ),
                                    Text(
                                      '${weather['humidity']}%', // Kelembapan
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
