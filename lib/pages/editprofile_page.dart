import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final int id;

  const EditProfilePage({super.key, required this.id});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>? userData;
  File? _imageFile; // File gambar profil baru yang dipilih user
  final ImagePicker _picker = ImagePicker(); // Objek untuk mengambil gambar
  String? _uploadedImageUrl;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isLoading = false;
  String? _error;
  bool _isFetching = true;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fetch data user berdasarkan ID
  Future<void> _fetchUserData() async {
    try {
      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app/user/${widget.id}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          if (mounted) {
            setState(() {
              userData = data['user'];
              _nameController.text = userData!['name'] ?? '';
              _emailController.text = userData!['email'] ?? '';
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _error = 'User data not found';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Server error: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to fetch user data: $e';
        });
      }
    }
  }

  // Method untuk mengunggah gambar ke server
  Future<void> _uploadImage(int userId) async {
    if (_imageFile == null) return;

    final url = Uri.parse(
      'https://finalpro-api-1013759214686.us-central1.run.app/user/$userId/upload-photo',
    );

    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('photo', _imageFile!.path),
    );
    var response = await request.send();

    if (response.statusCode == 200) {
      // Jika berhasil, buat timestamp untuk menghindari cache
      setState(() {
        _uploadedImageUrl =
            'https://finalpro-api-1013759214686.us-central1.run.app${userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}';
        _imageFile =
            null; // reset file lokal, supaya pakai network image terbaru
      });
    } else {
      throw Exception('Failed to upload image');
    }
  }

  // Method untuk menyimpan data profil
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app/user/${widget.id}',
      );

      Map<String, dynamic> bodyData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      };

      if (_passwordController.text.trim().isNotEmpty) {
        bodyData['password'] = _passwordController.text.trim();
      }

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        if (_imageFile != null) {
          await _uploadImage(widget.id);
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context, true); // Kembali dengan hasil berhasil
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Server error: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Method untuk membangun text field
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF0F6F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon,
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Method untuk mendapatkan gambar profil
  ImageProvider<Object> _getProfileImage() {
    // Cek apakah file gambar sudah dipilih
    if (_imageFile != null) {
      return FileImage(_imageFile!); // Jika ada file gambar yang dipilih
    }

    // Cek apakah URL gambar sudah ada
    if (_uploadedImageUrl != null) {
      return NetworkImage(
        _uploadedImageUrl!,
      ); // Jika ada gambar yang sudah diunggah
    }

    // Cek apakah ada foto dari backend user
    if (userData != null && userData!['photo'] != null) {
      return NetworkImage(
        'https://finalpro-api-1013759214686.us-central1.run.app${userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}',
      ); // Ambil gambar dari backend
    }

    // Fallback ke gambar profil default
    return const AssetImage(
      'assets/images/profile.jpg',
    ); // Gambar profil default
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          children: [
            // Header dengan gradient dan avatar besar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 0, bottom: 0),
              decoration: const BoxDecoration(
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
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _getProfileImage(),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextField(
                      label: 'Name',
                      controller: _nameController,
                      suffixIcon: const Icon(Icons.person, color: Colors.green),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: const Icon(Icons.email, color: Colors.green),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'New Password (leave blank to keep current)',
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.green.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Card(
                        color: Colors.red.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
