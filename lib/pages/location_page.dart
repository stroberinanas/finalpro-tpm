import 'dart:async'; // Mengimpor pustaka dart:async untuk fungsi asinkron seperti Future
import 'dart:convert'; // Mengimpor pustaka dart:convert untuk mengubah data JSON
import 'package:flutter/material.dart'; // Mengimpor pustaka untuk membuat antarmuka pengguna menggunakan Material Design
import 'package:geolocator/geolocator.dart'; // Mengimpor pustaka untuk mengambil data lokasi pengguna
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Mengimpor pustaka untuk menampilkan Google Map di aplikasi
import 'package:http/http.dart'
    as http; // Mengimpor pustaka HTTP untuk mengirimkan request HTTP

// Kelas untuk menggambarkan data Basecamp
class Basecamp {
  final String name;

  Basecamp({
    required this.name,
  }); // Konstruktor untuk inisialisasi nama Basecamp

  // Factory method untuk membuat objek Basecamp dari JSON
  factory Basecamp.fromJson(Map<String, dynamic> json) {
    return Basecamp(name: json['name']); // Mengambil 'name' dari data JSON
  }
}

// Kelas untuk menggambarkan data Pos
class Pos {
  final int id;
  final int basecampId;
  final String name;
  final String description;
  final int ketinggian;
  final double longitude;
  final double latitude;
  final bool isBasecamp;
  final Basecamp? basecamp;

  // Konstruktor untuk inisialisasi data Pos
  Pos({
    required this.id,
    required this.basecampId,
    required this.name,
    required this.description,
    required this.ketinggian,
    required this.longitude,
    required this.latitude,
    this.isBasecamp = false,
    this.basecamp,
  });

  // Factory method untuk membuat objek Pos dari JSON
  factory Pos.fromJson(Map<String, dynamic> json) {
    return Pos(
      id: json['id'],
      basecampId: json['basecamp_id'],
      name: json['name'],
      description: json['description'] ?? '',
      ketinggian: json['ketinggian'] ?? 0,
      longitude: double.parse(json['longitude']),
      latitude: double.parse(json['latitude']),
      isBasecamp: json['isBasecamp'] ?? false,
      basecamp:
          json['basecamp'] != null ? Basecamp.fromJson(json['basecamp']) : null,
    );
  }
}

// Halaman utama lokasi untuk menampilkan peta dan data Pos
class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

// State untuk mengelola data dan tampilan LocationPage
class _LocationPageState extends State<LocationPage> {
  final Completer<GoogleMapController> _controller =
      Completer(); // Kontroller untuk Google Map

  List<Pos> allPos = []; // Daftar semua Pos yang diambil dari API
  List<Pos> filteredPos = []; // Daftar Pos yang difilter berdasarkan pencarian
  Map<int, List<Pos>> basecampPosMap = {}; // Pemetaan Pos per Basecamp
  Set<Marker> markers =
      {}; // Set untuk menyimpan Marker (tanda lokasi) pada peta
  Pos? selectedPos; // Pos yang dipilih oleh pengguna
  LatLng? _userLocation; // Lokasi pengguna saat ini

  final List<Color> basecampColors = [
    Colors.red,
    Colors.orange,
    Colors.purple,
  ]; // Warna untuk Basecamp

  bool _loadingLocation = true; // Menandakan apakah lokasi sedang dimuat
  bool _isLoadingPosData = false; // Menandakan apakah data Pos sedang dimuat
  String _locationError =
      ''; // Menyimpan pesan error jika terjadi kesalahan lokasi

  final TextEditingController _searchController =
      TextEditingController(); // Controller untuk kolom pencarian

  static const LatLng _defaultLocation = LatLng(
    -7.7956,
    110.3695,
  ); // Lokasi default (Yogyakarta)

  @override
  void initState() {
    super.initState();
    _initLocationAndData(); // Menginisialisasi lokasi dan data Pos

    _searchController.addListener(() {
      _filterPosByDescription(
        _searchController.text,
      ); // Mengfilter Pos berdasarkan deskripsi pencarian
    });
  }

  // Fungsi untuk inisialisasi lokasi dan data Pos
  Future<void> _initLocationAndData() async {
    await _getUserLocation(); // Mendapatkan lokasi pengguna
    await _fetchPosData(); // Mengambil data Pos dari API
  }

  // Fungsi untuk mendapatkan lokasi pengguna
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError =
              'Location services are disabled'; // Pesan error jika layanan lokasi dimatikan
          _userLocation = _defaultLocation; // Menetapkan lokasi default
          _loadingLocation = false; // Selesai memuat lokasi
        });
        _showLocationDialog(
          'Location services are disabled. Please enable location services.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError =
                'Location permissions are denied'; // Pesan error jika izin lokasi ditolak
            _userLocation = _defaultLocation; // Menetapkan lokasi default
            _loadingLocation = false; // Selesai memuat lokasi
          });
          _showLocationDialog(
            'Location permissions are denied. Using default location.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permissions are permanently denied'; // Pesan error jika izin lokasi ditolak selamanya
          _userLocation = _defaultLocation; // Menetapkan lokasi default
          _loadingLocation = false; // Selesai memuat lokasi
        });
        _showLocationDialog(
          'Location permissions are permanently denied. Please enable in settings. Using default location.',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high, // Akurasi tinggi untuk mendapatkan lokasi
        timeLimit: const Duration(
          seconds: 15,
        ), // Batas waktu untuk mendapatkan lokasi
      );

      if (!mounted) return;

      setState(() {
        _userLocation = LatLng(
          position.latitude,
          position.longitude,
        ); // Mengupdate lokasi pengguna
        _loadingLocation = false; // Selesai memuat lokasi
        _locationError = ''; // Reset pesan error lokasi
      });

      print("Location obtained: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error getting user location: $e");

      if (!mounted) return;

      setState(() {
        _locationError =
            'Failed to get location: $e'; // Pesan error jika gagal mendapatkan lokasi
        _userLocation = _defaultLocation; // Menetapkan lokasi default
        _loadingLocation = false; // Selesai memuat lokasi
      });

      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null && mounted) {
          setState(() {
            _userLocation = LatLng(
              lastPosition.latitude,
              lastPosition.longitude,
            ); // Menggunakan lokasi terakhir yang diketahui
            _locationError =
                'Using last known location'; // Pesan bahwa menggunakan lokasi terakhir
          });
          print(
            "Using last known location: ${lastPosition.latitude}, ${lastPosition.longitude}",
          );
        }
      } catch (lastPosError) {
        print("Error getting last known position: $lastPosError");
      }
    }
  }

  // Fungsi untuk menampilkan dialog error lokasi
  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retryGetLocation(); // Retry untuk mendapatkan lokasi
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mencoba kembali mendapatkan lokasi
  Future<void> _retryGetLocation() async {
    setState(() {
      _loadingLocation = true; // Menandakan loading sedang berlangsung
      _locationError = ''; // Reset pesan error lokasi
    });
    await _getUserLocation(); // Mendapatkan lokasi ulang
  }

  // Fungsi untuk mengambil data Pos dari API
  Future<void> _fetchPosData() async {
    if (!mounted) return;
    setState(() => _isLoadingPosData = true); // Menandakan loading data Pos
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://finalpro-api-1013759214686.us-central1.run.app/pos',
            ),
          )
          .timeout(const Duration(seconds: 10)); // Timeout untuk request

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(
          response.body,
        ); // Decode JSON response
        allPos =
            data
                .map((e) => Pos.fromJson(e))
                .toList(); // Mengubah data JSON menjadi list Pos
        filteredPos = List.from(allPos); // Menyaring Pos berdasarkan pencarian

        basecampPosMap.clear(); // Clear pemetaan Basecamp Pos
        for (var pos in allPos) {
          basecampPosMap
              .putIfAbsent(pos.basecampId, () => [])
              .add(pos); // Menyusun Pos berdasarkan Basecamp
        }

        await _updateMarkers(); // Memperbarui markers (penanda) di peta
      } else {
        throw Exception(
          'Failed to load positions: ${response.statusCode}',
        ); // Menangani jika response gagal
      }
    } catch (e) {
      print('Error fetchPosData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        ); // Menampilkan pesan error jika gagal
      }
    }
    if (!mounted) return;
    setState(() => _isLoadingPosData = false); // Selesai memuat data Pos
  }

  // Fungsi untuk memfilter Pos berdasarkan deskripsi pencarian
  void _filterPosByDescription(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPos = List.from(allPos); // Reset filter jika query kosong
      });
    } else {
      setState(() {
        filteredPos =
            allPos
                .where(
                  (pos) => pos.description.toLowerCase().contains(
                    // Pencarian deskripsi Pos menggunakan toLowerCase untuk case-insensitive
                    query.toLowerCase(),
                  ),
                )
                .toList(); // Filter Pos berdasarkan query pencarian
      });
    }
    _updateMarkers(); // Memperbarui markers setelah filter
  }

  // Fungsi untuk mendapatkan icon marker untuk Pos
  Future<BitmapDescriptor> _getBitmapDescriptor(
    Color color,
    bool isBasecamp,
  ) async {
    if (isBasecamp) {
      return BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ); // Icon marker untuk basecamp
    } else {
      if (color == Colors.red) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else if (color == Colors.orange) {
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      } else if (color == Colors.purple) {
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      } else {
        return BitmapDescriptor.defaultMarker;
      }
    }
  }

  // Fungsi untuk memperbarui markers di peta
  Future<void> _updateMarkers() async {
    Set<Marker> newMarkers = {}; // Set baru untuk markers

    if (_userLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ), // Marker untuk lokasi pengguna
          infoWindow: InfoWindow(
            title:
                _locationError.isEmpty
                    ? 'Your Location'
                    : 'Your Location ($_locationError)', // Menampilkan informasi lokasi pengguna
          ),
        ),
      );
    }

    int colorIndex = 0;
    for (var entry in basecampPosMap.entries) {
      List<Pos> posList = entry.value;
      posList =
          posList
              .where((pos) => filteredPos.contains(pos))
              .toList(); // Filter Pos sesuai dengan pencarian

      if (posList.isEmpty) continue;

      Color color =
          basecampColors[colorIndex %
              basecampColors.length]; // Mengambil warna gradien untuk Basecamp

      for (var pos in posList) {
        BitmapDescriptor icon = await _getBitmapDescriptor(
          color,
          pos.isBasecamp,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId('marker_${pos.id}'),
            position: LatLng(pos.latitude, pos.longitude),
            icon: icon, // Menggunakan icon sesuai warna
            infoWindow: InfoWindow(
              title: pos.name,
              snippet: pos.description,
            ), // InfoWindow yang muncul saat marker ditekan
            onTap:
                () =>
                    _showPosDetail(pos), // Menampilkan detail Pos saat ditekan
          ),
        );
      }
      colorIndex++;
    }

    if (!mounted) return;
    setState(() {
      markers = newMarkers; // Update markers di UI
    });
  }

  // Fungsi untuk menampilkan detail Pos saat marker ditekan
  void _showPosDetail(Pos pos) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pos.name} - ${pos.description}', // Nama dan deskripsi Pos
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pos.basecamp?.name ?? 'Unknown Basecamp',
                ), // Menampilkan nama Basecamp
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.height,
                      color: Colors.blue,
                    ), // Ikon ketinggian
                    const SizedBox(width: 8),
                    Text(
                      'Elevation: ${pos.ketinggian} M', // Ketinggian Pos
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed:
                        () => Navigator.of(context).pop(), // Menutup detail
                    child: const Text('Hide'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller pencarian
    super.dispose(); // Memanggil dispose dari superclass
  }

  @override
  Widget build(BuildContext context) {
    // Jika lokasi masih loading, tampilkan spinner dan pesan
    if (_loadingLocation) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.green,
          title: const Text(
            'Map Pos and Basecamp',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green), // Loading spinner
              SizedBox(height: 16),
              Text('Getting your location...'), // Pesan menunggu lokasi
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          'Map Pos and Basecamp',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  _userLocation ?? _defaultLocation, // Posisi awal kamera peta
              zoom: 14,
            ),
            markers: markers, // Menampilkan markers di peta
            mapType: MapType.satellite, // Menggunakan tipe peta satelit
            myLocationEnabled: true, // Mengaktifkan tombol lokasi pengguna
            myLocationButtonEnabled: true, // Menampilkan tombol lokasi
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller); // Menyelesaikan kontrol peta
            },
          ),
          Positioned(
            top: 10,
            left: 53,
            right: 55,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              child: TextField(
                controller:
                    _searchController, // Controller untuk kolom pencarian
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search Pos', // Placeholder untuk pencarian
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) async {
                  final match = filteredPos.firstWhere(
                    (pos) => pos.description.toLowerCase().contains(
                      value.toLowerCase(),
                    ),
                    orElse:
                        () => Pos(
                          id: -1,
                          basecampId: -1,
                          name: '',
                          description: '',
                          ketinggian: 0,
                          longitude: 0.0,
                          latitude: 0.0,
                        ),
                  );

                  if (match.id == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No Pos Found'),
                      ), // Pesan jika tidak ditemukan
                    );
                  } else {
                    final controller = await _controller.future;
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(match.latitude, match.longitude),
                        17,
                      ), // Menunjukkan Pos yang ditemukan pada peta
                    );
                    setState(() {
                      selectedPos = match; // Set Pos yang dipilih
                    });
                  }
                },
              ),
            ),
          ),
          if (_locationError.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationError,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: _retryGetLocation, // Retry mendapatkan lokasi
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
