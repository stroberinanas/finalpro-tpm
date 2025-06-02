import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Basecamp {
  final String name;

  Basecamp({required this.name});

  factory Basecamp.fromJson(Map<String, dynamic> json) {
    return Basecamp(name: json['name']);
  }
}

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

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final Completer<GoogleMapController> _controller = Completer();

  List<Pos> allPos = [];
  List<Pos> filteredPos = [];
  Map<int, List<Pos>> basecampPosMap = {};
  Set<Marker> markers = {};
  Pos? selectedPos;
  LatLng? _userLocation;

  final List<Color> basecampColors = [Colors.red, Colors.orange, Colors.purple];

  bool _loadingLocation = true;
  bool _isLoadingPosData = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocationAndData();

    _searchController.addListener(() {
      _filterPosByDescription(_searchController.text);
    });
  }

  Future<void> _initLocationAndData() async {
    await _getUserLocation();
    await _fetchPosData();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print("Permission lokasi ditolak");
          if (!mounted) return;
          setState(() => _loadingLocation = false);
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });
    } catch (e) {
      print("Error mendapatkan lokasi user: $e");
      if (!mounted) return;
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _fetchPosData() async {
    if (!mounted) return;
    setState(() => _isLoadingPosData = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/pos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        allPos = data.map((e) => Pos.fromJson(e)).toList();
        filteredPos = List.from(allPos);

        basecampPosMap.clear();
        for (var pos in allPos) {
          basecampPosMap.putIfAbsent(pos.basecampId, () => []).add(pos);
        }

        await _updateMarkers();
      } else {
        throw Exception('Failed to load positions');
      }
    } catch (e) {
      print('Error fetchPosData: $e');
    }
    if (!mounted) return;
    setState(() => _isLoadingPosData = false);
  }

  void _filterPosByDescription(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPos = List.from(allPos);
      });
    } else {
      setState(() {
        filteredPos =
            allPos
                .where(
                  (pos) => pos.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
    _updateMarkers();
  }

  Future<BitmapDescriptor> _getBitmapDescriptor(
    Color color,
    bool isBasecamp,
  ) async {
    if (isBasecamp) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
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

  Future<void> _updateMarkers() async {
    Set<Marker> newMarkers = {};

    if (_userLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    int colorIndex = 0;
    for (var entry in basecampPosMap.entries) {
      int basecampId = entry.key;
      List<Pos> posList = entry.value;

      posList = posList.where((pos) => filteredPos.contains(pos)).toList();

      if (posList.isEmpty) continue;

      Color color = basecampColors[colorIndex % basecampColors.length];

      for (var pos in posList) {
        BitmapDescriptor icon = await _getBitmapDescriptor(
          color,
          pos.isBasecamp,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId('marker_${pos.id}'),
            position: LatLng(pos.latitude, pos.longitude),
            icon: icon,
            infoWindow: InfoWindow(title: pos.name, snippet: pos.description),
            onTap: () => _showPosDetail(pos),
          ),
        );
      }
      colorIndex++;
    }

    if (!mounted) return;
    setState(() {
      markers = newMarkers;
    });
  }

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
                  '${pos.name} - ${pos.description}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(pos.basecamp?.name ?? 'Unknown Basecamp'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.height, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Elevation: ${pos.ketinggian} M',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: CircularProgressIndicator(color: Colors.green),
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
              target: _userLocation!,
              zoom: 14,
            ),
            markers: markers,
            mapType: MapType.satellite,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search Pos',
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
                      const SnackBar(content: Text('No Pos Found')),
                    );
                  } else {
                    final controller = await _controller.future;
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(match.latitude, match.longitude),
                        17,
                      ),
                    );
                    setState(() {
                      selectedPos = match;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
