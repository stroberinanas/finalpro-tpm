import 'dart:convert';
import 'package:finalpro/pages/editprofile_page.dart';
import 'package:finalpro/pages/login_page.dart';
import 'package:finalpro/pages/sos_page.dart'; // Import SOSPage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const ProfilePage({super.key, required this.name, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? id;
  Map<String, dynamic>? _userData;
  bool _isLoadingData = false;
  bool _isDetailExpanded = false;
  String? _updatedPhotoUrl;
  String? _error; // Deklarasi untuk _error

  // State untuk wishlist
  bool _isWishlistExpanded = false;
  bool _isLoadingWishlist = false;
  List<dynamic> _wishlistBasecamps = [];

  @override
  void initState() {
    super.initState();
    _loadId();
  }

  Future<void> _loadId() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedId = prefs.getInt('id');
    setState(() {
      id = loadedId;
    });
    if (loadedId != null) {
      await _fetchUserData();
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
        );
      }
    }
  }

  Future<void> _fetchUserData() async {
    if (id == null) return;

    setState(() => _isLoadingData = true);

    try {
      final url = Uri.parse('http://10.0.2.2:5000/user/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _userData = data['user'];
            _isLoadingData = false;
            if (_userData?['photo'] != null) {
              _updatedPhotoUrl =
                  'http://10.0.2.2:5000${_userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}';
            } else {
              _updatedPhotoUrl = null;
            }
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load user data';
            _isLoadingData = false;
            _updatedPhotoUrl = null;
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoadingData = false;
          _updatedPhotoUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection failed: $e';
        _isLoadingData = false;
        _updatedPhotoUrl = null;
      });
    }
  }

  void _openEditProfile() {
    if (id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditProfilePage(id: id!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found, please Login Again')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  ImageProvider<Object> _getProfileImage() {
    if (_userData != null) {
      final photo = _userData!['photo'];
      if (photo != null && photo is String && photo.isNotEmpty) {
        return NetworkImage(
          'http://10.0.2.2:5000${_userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      final name = _userData!['name'];
      if (name != null && name is String && name.isNotEmpty) {
        final encodedName = Uri.encodeComponent(name);
        final fallbackUrl =
            'https://ui-avatars.com/api/?name=$encodedName&background=0D8ABC&color=fff';
        return NetworkImage(fallbackUrl);
      }
    }
    return const AssetImage('assets/images/profile.jpg');
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('email');
    await prefs.remove('name');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

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

      final url = Uri.parse('http://10.0.2.2:5000/user/$id');

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

  Future<List<dynamic>> _fetchWishlistBasecamps(Set<int> wishlistIds) async {
    final url = Uri.parse('http://10.0.2.2:5000/basecamp');
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

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _getProfileImage(),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData?['name'] ?? widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color.fromARGB(255, 34, 34, 34),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _userData?['email'] ?? widget.email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: _openEditProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                            (basecamp) => ListTile(
                              leading:
                                  (basecamp['photo'] != null &&
                                          basecamp['photo'].isNotEmpty)
                                      ? Image.asset(
                                        basecamp['photo'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                              title: Text(
                                basecamp['name'] ?? 'Nama tidak tersedia',
                              ),
                              subtitle: Text(
                                basecamp['hiking_time'] != null
                                    ? 'Hiking Time : ${basecamp['hiking_time']} Hours'
                                    : 'Hiking Time Not Available',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  buildBorderedTile(
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.library_books_outlined,
                        color: Colors.green,
                      ),
                      title: const Text("Testimonial"),
                      initiallyExpanded: _isDetailExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isDetailExpanded = expanded;
                        });
                      },
                      children: const [
                        ListTile(title: Text("keren mantap luar biasa")),
                      ],
                    ),
                  ),

                  // Menu SOS ditambahkan di sini
                  buildBorderedTile(
                    child: ListTile(
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                      ),
                      title: const Text("SOS"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SOSPage()),
                        );
                      },
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
