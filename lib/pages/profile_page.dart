import 'dart:convert'; // Import untuk mengubah data ke format JSON
import 'package:finalpro/pages/editprofile_page.dart'; // Import halaman Edit Profile
import 'package:finalpro/pages/login_page.dart'; // Import halaman Login
import 'package:flutter/material.dart'; // Import pustaka material untuk UI
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk penyimpanan lokal (SharedPreferences)
import 'package:http/http.dart' as http; // Import untuk melakukan HTTP request

// ProfilePage untuk menampilkan halaman profil user
class ProfilePage extends StatefulWidget {
  final String name; // Nama pengguna
  final String email; // Email pengguna

  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
  }); // Konstruktor untuk menerima nama dan email

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? id; // ID pengguna yang akan diambil dari SharedPreferences
  Map<String, dynamic>? _userData; // Menyimpan data pengguna
  bool _isLoadingData = false; // Flag untuk memeriksa apakah data sedang dimuat
  String? _updatedPhotoUrl; // Menyimpan URL foto pengguna yang diperbarui
  String? _error; // Menyimpan pesan error

  // Wishlist State
  bool _isWishlistExpanded = false; // Flag untuk status ekspansi wishlist
  bool _isLoadingWishlist =
      false; // Flag untuk memeriksa apakah wishlist sedang dimuat
  List<dynamic> _wishlistBasecamps =
      []; // Menyimpan daftar basecamp di wishlist

  // Inisialisasi state dan load ID pengguna saat halaman dimuat
  @override
  void initState() {
    super.initState();
    _loadId(); // Memanggil fungsi untuk mengambil ID dari SharedPreferences
  }

  // Fungsi untuk mengambil ID pengguna dari SharedPreferences
  Future<void> _loadId() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    final loadedId = prefs.getInt(
      'id',
    ); // Mendapatkan ID pengguna dari SharedPreferences
    setState(() {
      id = loadedId; // Menyimpan ID ke dalam state
    });

    if (loadedId != null) {
      await _fetchUserData(); // Jika ID ada, ambil data pengguna
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found, please Login Again'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        ); // Jika ID tidak ditemukan, arahkan ke halaman Login
      }
    }
  }

  // Fungsi untuk mengambil data pengguna dari backend menggunakan HTTP GET
  Future<void> _fetchUserData() async {
    if (id == null) return; // Jika ID null, tidak perlu fetch data

    setState(
      () => _isLoadingData = true,
    ); // Set loading ke true saat memulai pemuatan data

    try {
      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app/user/$id',
      ); // URL untuk mengambil data pengguna berdasarkan ID
      final response = await http.get(url); // Melakukan HTTP GET request

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        ); // Mengonversi response JSON menjadi Map
        if (data['success'] == true) {
          setState(() {
            _userData = data['user']; // Menyimpan data pengguna dalam state
            _isLoadingData =
                false; // Set loading ke false setelah data berhasil diambil
            if (_userData?['photo'] != null) {
              _updatedPhotoUrl =
                  'https://finalpro-api-1013759214686.us-central1.run.app${_userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}';
            } else {
              _updatedPhotoUrl = null; // Jika tidak ada foto, set null
            }
          });
        } else {
          setState(() {
            _error =
                data['message'] ??
                'Failed to load user data'; // Tampilkan pesan error jika ada
            _isLoadingData = false;
            _updatedPhotoUrl = null;
          });
        }
      } else {
        setState(() {
          _error =
              'Server error: ${response.statusCode}'; // Error jika server gagal memberikan response
          _isLoadingData = false;
          _updatedPhotoUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection failed: $e'; // Tangani error koneksi
        _isLoadingData = false;
        _updatedPhotoUrl = null;
      });
    }
  }

  // Fungsi untuk membuka halaman edit profile
  void _openEditProfile() {
    if (id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditProfilePage(id: id!)),
      ); // Jika ID ada, arahkan ke halaman edit profile
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found, please Login Again')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      ); // Jika ID tidak ditemukan, arahkan ke halaman login
    }
  }

  // Fungsi untuk mendapatkan gambar profil
  ImageProvider<Object> _getProfileImage() {
    if (_userData != null) {
      final photo = _userData!['photo'];
      if (photo != null && photo is String && photo.isNotEmpty) {
        return NetworkImage(
          'https://finalpro-api-1013759214686.us-central1.run.app${_userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}',
        ); // Jika foto tersedia, tampilkan gambar dari URL
      }

      // final name = _userData!['name'];
      // if (name != null && name is String && name.isNotEmpty) {
      //   final encodedName = Uri.encodeComponent(name);
      //   final fallbackUrl =
      //       'https://ui-avatars.com/api/?name=$encodedName&background=0D8ABC&color=fff';
      //   return NetworkImage(
      //     fallbackUrl,
      //   ); // Jika tidak ada foto, gunakan avatar berdasarkan nama
      // }
    }
    return const AssetImage(
      'assets/images/profile.jpg',
    ); // Gambar profil default jika tidak ada data
  }

  // Fungsi logout
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('email');
    await prefs.remove('name');

    // Arahkan ke halaman login setelah logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // Fungsi untuk menghapus akun
  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? id = prefs.getInt('id');

      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found, please login again'),
          ),
        );
        return;
      }

      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app/user/$id',
      );

      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['message'] != null) {
          await prefs.clear();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
    }
  }

  // Fungsi untuk memuat ID wishlist dari SharedPreferences
  Future<Set<int>> _loadWishlistIds() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id == null) return {};
    final key = 'wishlist_$id';
    final listString = prefs.getStringList(key);
    if (listString == null) return {};
    return listString
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e != 0)
        .toSet();
  }

  // Fungsi untuk mengambil daftar basecamp yang ada di wishlist
  Future<List<dynamic>> _fetchWishlistBasecamps(Set<int> wishlistIds) async {
    final url = Uri.parse(
      'https://finalpro-api-1013759214686.us-central1.run.app/basecamp',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> allBasecamps = data;
      return allBasecamps
          .where((bc) => wishlistIds.contains(bc['id']))
          .toList();
    } else {
      return [];
    }
  }

  // Fungsi untuk memuat data wishlist dan basecamp
  Future<void> _loadWishlistData() async {
    if (id == null) return;
    setState(() {
      _isLoadingWishlist = true;
    });
    final wishlistIds = await _loadWishlistIds();
    final wishlistBasecamps = await _fetchWishlistBasecamps(wishlistIds);
    setState(() {
      _wishlistBasecamps = wishlistBasecamps;
      _isLoadingWishlist = false;
    });
  }

  // Fungsi untuk membuat tile dengan border
  Widget buildBorderedTile({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green.shade700, width: 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // UI untuk halaman profil
  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      body: Column(
        children: [
          // Header dengan gradient dan avatar besar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43EA7A), Color(0xFF1B8D3B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _getProfileImage(),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _openEditProfile,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _userData?['name'] ?? widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _userData?['email'] ?? widget.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: _openEditProfile,
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  buildBorderedTile(
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.bookmark_border,
                        color: Colors.green,
                      ),
                      title: const Text("Your Wishlist"),
                      initiallyExpanded: _isWishlistExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isWishlistExpanded = expanded;
                        });
                        if (expanded) {
                          _loadWishlistData();
                        }
                      },
                      children: [
                        if (_isLoadingWishlist)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_wishlistBasecamps.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text("Wishlist Not Found")),
                          )
                        else
                          ..._wishlistBasecamps.map(
                            (basecamp) => Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                leading:
                                    (basecamp['photo'] != null &&
                                            basecamp['photo'].isNotEmpty)
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.asset(
                                            basecamp['photo'],
                                            width: 54,
                                            height: 54,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                                title: Text(
                                  basecamp['name'] ?? 'Nama tidak tersedia',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  basecamp['hiking_time'] != null
                                      ? 'Hiking Time : ${basecamp['hiking_time']} Hours'
                                      : 'Hiking Time Not Available',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  buildBorderedTile(
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Colors.green,
                      ),
                      title: const Text("Delete Account"),
                      onTap: () => _deleteAccount(context),
                    ),
                  ),
                  buildBorderedTile(
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                      ),
                      title: const Text("Logout"),
                      onTap: () => _logout(context),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
