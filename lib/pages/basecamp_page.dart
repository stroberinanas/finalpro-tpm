import 'dart:convert'; // Untuk decoding data JSON
import 'package:finalpro/notification_service.dart'; // Untuk notifikasi
import 'package:finalpro/pages/detailbasecamp_page.dart'; // Untuk halaman detail basecamp
import 'package:flutter/material.dart'; // Menggunakan Flutter Material Design
import 'package:http/http.dart' as http; // Untuk melakukan HTTP request
import 'package:permission_handler/permission_handler.dart'; // Untuk menangani izin akses
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan data lokal menggunakan SharedPreferences

// Widget utama halaman BasecampPage
class BasecampPage extends StatefulWidget {
  const BasecampPage({super.key});

  @override
  State<BasecampPage> createState() => _BasecampPageState();
}

class _BasecampPageState extends State<BasecampPage> {
  String _searchText = ''; // teks pencarian yang diinput user
  bool _sortByHikingTimeAsc =
      true; // urutan sorting waktu hiking (true=asc, false=desc)
  String _selectedProvince =
      'All Province'; // provinsi yang dipilih pada dropdown filter
  List<dynamic> _basecampList = []; // data basecamp yang diambil dari API
  bool _isLoading = true; // indikator sedang memuat data basecamp
  String? _errorMessage; // pesan error bila ada masalah fetch data
  Set<int> _wishlistIds = {}; // set id basecamp yg dimasukkan wishlist

  @override
  void initState() {
    super.initState();
    fetchBasecampList(); // ambil data basecamp saat inisialisasi
    loadWishlist(); // load wishlist user dari SharedPreferences
  }

  // Load wishlist dari SharedPreferences sesuai id user
  Future<void> loadWishlist() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengakses SharedPreferences
    final idUser = prefs.getInt(
      'id',
    ); // Mengambil id user dari SharedPreferences
    if (idUser != null) {
      final key = 'wishlist_$idUser'; // Membuat key berdasarkan id user
      final List<String>? savedList = prefs.getStringList(
        key,
      ); // Mengambil data wishlist
      if (savedList != null) {
        setState(() {
          // Mengkonversi List<String> ke Set<int> dan menghapus nilai 0
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
    final prefs =
        await SharedPreferences.getInstance(); // Mengakses SharedPreferences
    final idUser = prefs.getInt('id'); // Mengambil id user
    if (idUser != null) {
      final key = 'wishlist_$idUser'; // Membuat key berdasarkan id user
      // Menyimpan Set<int> sebagai list string di SharedPreferences
      await prefs.setStringList(
        key,
        _wishlistIds.map((e) => e.toString()).toList(),
      );
    }
  }

  // Ambil daftar basecamp dari API
  Future<void> fetchBasecampList() async {
    final url =
        "https://finalpro-api-1013759214686.us-central1.run.app/basecamp"; // URL API
    try {
      final response = await http.get(
        Uri.parse(url),
      ); // Request HTTP GET ke API
      if (response.statusCode == 200) {
        // Jika status code 200 (OK)
        final data = jsonDecode(response.body); // Parsing response JSON
        if (data is List) {
          setState(() {
            _basecampList = data; // Simpan data basecamp ke state
            _isLoading = false; // Selesai memuat data
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage =
                'Invalid data format from server'; // Format data tidak valid
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Failed to load basecamp, status code: ${response.statusCode}"; // Jika gagal mengambil data
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Error fetching basecamp: $e"; // Menangani error jika ada masalah saat fetch data
        _isLoading = false;
      });
    }
  }

  // Toggle wishlist: tambah atau hapus id basecamp
  void toggleWishlist(int basecampId) {
    setState(() {
      if (_wishlistIds.contains(basecampId)) {
        _wishlistIds.remove(basecampId); // Hapus dari wishlist jika sudah ada
      } else {
        _wishlistIds.add(basecampId); // Tambah ke wishlist jika belum ada
      }
    });
    saveWishlist(); // Simpan perubahan ke SharedPreferences
  }

  // Toggle urutan sorting (asc/desc)
  void _toggleSortOrder() {
    setState(() {
      _sortByHikingTimeAsc = !_sortByHikingTimeAsc; // Mengubah urutan sorting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya (HomePage)
          },
        ),
        title: const Text(
          'Basecamp Page',
          style: TextStyle(
            color: Colors.white, // Mengatur warna teks menjadi putih
          ),
        ),
        centerTitle: true, // Mengatur judul agar berada di tengah
      ),
      // Jika sedang loading tampilkan CircularProgressIndicator, jika tidak tampilkan konten
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Loading spinner
              : content(), // Menampilkan konten utama jika tidak loading
    );
  }

  // Konten halaman BasecampPage
  Widget content() {
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!),
      ); // Tampilkan pesan error jika ada
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
          ? hikingA.compareTo(hikingB) // Ascending
          : hikingB.compareTo(hikingA); // Descending
    });

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
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
                    hintText: "ex : Candi Cetho", // Placeholder text
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14,
                    ),
                    border: InputBorder.none, // Tanpa border
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 18,
                    ), // Icon pencarian
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
                  child: DropdownButton<String>(
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
                          _selectedProvince =
                              newValue; // Ubah provinsi yang dipilih
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
                      : Icons.arrow_downward, // Ubah ikon berdasarkan urutan
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
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.13),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar basecamp dengan rounded dan shadow
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                  child:
                                      basecamp['photo'] != null &&
                                              basecamp['photo'].isNotEmpty
                                          ? Image.asset(
                                            basecamp['photo'],
                                            width: double.infinity,
                                            height: 180,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            width: double.infinity,
                                            height: 180,
                                            color: Colors.grey.shade200,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.image_not_supported,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'No Image',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              basecamp['name'] ??
                                                  'Basecamp Has No Name',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              toggleWishlist(
                                                basecampId,
                                              ); // Toggle wishlist
                                              String body =
                                                  _wishlistIds.contains(
                                                        basecampId,
                                                      )
                                                      ? "Bookmark Saved"
                                                      : "Bookmark Removed"; // Menentukan pesan berdasarkan status bookmark
                                              String title = basecamp['name'];
                                              await Permission.notification
                                                  .request(); // Meminta izin notifikasi
                                              await NotificationService().show(
                                                title,
                                                body,
                                              );
                                            },
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              transitionBuilder:
                                                  (child, anim) =>
                                                      ScaleTransition(
                                                        scale: anim,
                                                        child: child,
                                                      ),
                                              child: Icon(
                                                _wishlistIds.contains(
                                                      basecampId,
                                                    )
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                                key: ValueKey(
                                                  _wishlistIds.contains(
                                                    basecampId,
                                                  ),
                                                ),
                                                color:
                                                    _wishlistIds.contains(
                                                          basecampId,
                                                        )
                                                        ? Colors.purpleAccent
                                                        : Colors.grey,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _infoChip(
                                            icon: Icons.access_time,
                                            label:
                                                basecamp['hiking_time'] != null
                                                    ? '${basecamp['hiking_time']} Hours'
                                                    : 'No Time',
                                            color: Colors.blue.shade100,
                                            iconColor: Colors.blue,
                                          ),
                                          const SizedBox(width: 12),
                                          _infoChip(
                                            icon: Icons.height_rounded,
                                            label:
                                                basecamp['elevation'] != null
                                                    ? '${basecamp['elevation']} M'
                                                    : 'No Elevation',
                                            color: Colors.orange.shade100,
                                            iconColor: Colors.deepOrangeAccent,
                                          ),
                                        ],
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
        ],
      ),
    );
  }

  // Chip info hiking time/elevation
  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor), // Tampilkan ikon
          const SizedBox(width: 6), // Spasi antara ikon dan teks
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
