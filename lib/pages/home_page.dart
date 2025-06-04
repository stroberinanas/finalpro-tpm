import 'dart:convert';
import 'package:finalpro/pages/detailbasecamp_page.dart';
import 'package:finalpro/pages/location_page.dart';
import 'package:finalpro/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Widget utama halaman HomePage yang menerima parameter name dan email
class HomePage extends StatefulWidget {
  final String name;
  final String email;

  const HomePage({super.key, required this.name, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0; // indeks menu navigasi bawah saat ini (0 = home)
  String _searchText = ''; // teks pencarian yang diinput user
  bool _sortByHikingTimeAsc =
      true; // urutan sorting waktu hiking (true=asc, false=desc)
  String _selectedProvince =
      'All Province'; // provinsi yang dipilih pada dropdown filter
  List<dynamic> _basecampList = []; // data basecamp yang diambil dari API
  bool _isLoading = true; // indikator sedang memuat data basecamp
  String? _errorMessage; // pesan error bila ada masalah fetch data
  Set<int> _wishlistIds = {}; // set id basecamp yg dimasukkan wishlist
  late final List<Widget> _pages; // halaman lain selain home

  @override
  void initState() {
    super.initState();
    fetchBasecampList(); // ambil data basecamp saat inisialisasi
    loadWishlist(); // load wishlist user dari SharedPreferences
    _pages = [
      Container(), // kosong untuk home, konten di-handle oleh content()
      LocationPage(), // halaman lokasi dengan peta
      ProfilePage(name: widget.name, email: widget.email), // halaman profil
    ];
  }

  // Load wishlist dari SharedPreferences sesuai id user
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('id');
    if (idUser != null) {
      final key = 'wishlist_$idUser';
      final List<String>? savedList = prefs.getStringList(key);
      if (savedList != null) {
        setState(() {
          _wishlistIds =
              savedList
                  .map((e) => int.tryParse(e) ?? 0) // konversi ke int
                  .where((e) => e != 0) // abaikan 0
                  .toSet();
        });
      }
    }
  }

  // Simpan wishlist ke SharedPreferences
  Future<void> saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('id');
    if (idUser != null) {
      final key = 'wishlist_$idUser';
      await prefs.setStringList(
        key,
        _wishlistIds.map((e) => e.toString()).toList(),
      );
    }
  }

  // Ambil daftar basecamp dari API
  Future<void> fetchBasecampList() async {
    final url = "http://10.0.2.2:5000/basecamp";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            _basecampList = data; // simpan data ke state
            _isLoading = false; // selesai loading
            _errorMessage = null;
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

  // Ambil AppBar hanya jika sedang di halaman Home (index 0)
  PreferredSizeWidget? getAppBar() {
    if (_currentNavIndex != 0)
      return null; // sembunyikan AppBar di halaman lain
    return AppBar(
      automaticallyImplyLeading: false, // hilangkan tombol back default
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Center(
        child: Text(
          'Hi, Explorers!',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  // Toggle wishlist: tambah atau hapus id basecamp
  void toggleWishlist(int basecampId) {
    setState(() {
      if (_wishlistIds.contains(basecampId)) {
        _wishlistIds.remove(basecampId);
      } else {
        _wishlistIds.add(basecampId);
      }
    });
    saveWishlist();
  }

  // Toggle urutan sorting (asc/desc)
  void _toggleSortOrder() {
    setState(() {
      _sortByHikingTimeAsc = !_sortByHikingTimeAsc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body:
          _currentNavIndex == 0
              ? content()
              : _pages[_currentNavIndex], // tampilkan halaman sesuai index menu
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_sharp),
            label: 'Pos Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_contact_calendar_sharp),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Konten halaman HomePage
  Widget content() {
    if (_isLoading) {
      // Jika data sedang dimuat, tampilkan spinner loading
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      // Jika ada error saat fetch data, tampilkan pesan error
      return Center(child: Text(_errorMessage!));
    }

    // Filter basecamp berdasarkan pencarian dan provinsi
    List<dynamic> filteredData =
        _basecampList.where((basecamp) {
          final name = (basecamp['name'] ?? '').toString();
          final description = (basecamp['description'] ?? '').toString();
          final searchMatch = name.toLowerCase().contains(
            _searchText.toLowerCase(),
          );

          // Jika pilih All Province, tampilkan semua, kalau tidak cocokkan dengan provinsi
          final provinceMatch =
              _selectedProvince == 'All Province'
                  ? true
                  : description.contains(_selectedProvince);

          return searchMatch && provinceMatch;
        }).toList();

    // Urutkan daftar berdasarkan hiking_time sesuai _sortByHikingTimeAsc
    filteredData.sort((a, b) {
      final hikingA = a['hiking_time'] ?? 0;
      final hikingB = b['hiking_time'] ?? 0;
      return _sortByHikingTimeAsc
          ? hikingA.compareTo(hikingB)
          : hikingB.compareTo(hikingA);
    });

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Carousel gambar basecamp
          carousel.CarouselSlider(
            items:
                [
                  'assets/images/lawu1.jpg',
                  'assets/images/lawu2.jpg',
                  'assets/images/lawu3.jpeg',
                  'assets/images/lawu4.jpg',
                ].map((imagePath) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
            options: carousel.CarouselOptions(
              height: 120,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
          ),
          const SizedBox(height: 10),

          // Row untuk kotak pencarian
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 340,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value; // update teks pencarian
                    });
                  },
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintText: "ex : Candi Cetho",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Row untuk dropdown select provinsi dan tombol sort
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: // Dropdown dengan pilihan 'All Province' + provinsi lain
                      DropdownButton<String>(
                    value: _selectedProvince,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    dropdownColor: Colors.green.withOpacity(0.8),
                    items:
                        ['All Province', 'Jawa Tengah', 'Jawa Timur'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedProvince = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 17),
              ElevatedButton.icon(
                onPressed: _toggleSortOrder,
                icon: Icon(
                  _sortByHikingTimeAsc
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 18,
                ),
                label: const Text('Sort by Hiking Time'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // List basecamp yang di-filter dan diurutkan
          Expanded(
            child:
                filteredData.isEmpty
                    ? const Center(child: Text("Basecamp Not Found"))
                    : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final basecamp = filteredData[index];
                        final int basecampId = basecamp['id'] ?? 0;

                        return GestureDetector(
                          onTap: () {
                            // Navigasi ke halaman detail basecamp saat item diklik
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => DetailBasecampPage(
                                      basecampId: basecampId,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(15),

                            // Dekorasi kartu: background putih dengan shadow halus, tanpa border
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child:
                                      basecamp['photo'] != null &&
                                              basecamp['photo'].isNotEmpty
                                          ? Image.asset(
                                            basecamp['photo'],
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.fill,
                                          )
                                          : Container(
                                            width: double.infinity,
                                            height: 180,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    basecamp['name'] ?? 'Basecamp Has No Name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        basecamp['hiking_time'] != null
                                            ? '${basecamp['hiking_time'].toString()} Hours'
                                            : 'Basecamp Has No Time',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      const Icon(
                                        Icons.height_rounded,
                                        size: 20,
                                        color: Colors.deepOrangeAccent,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        basecamp['elevation'] != null
                                            ? '${basecamp['elevation'].toString()} M'
                                            : 'Basecamp Has No Elevation',
                                        style: const TextStyle(
                                          color: Colors.deepOrangeAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(
                                          _wishlistIds.contains(basecampId)
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color:
                                              _wishlistIds.contains(basecampId)
                                                  ? Colors.purpleAccent
                                                  : Colors.grey,
                                        ),

                                        onPressed:
                                            () => toggleWishlist(basecampId),
                                      ),
                                      const SizedBox(width: 6),
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
        ],
      ),
    );
  }
}
