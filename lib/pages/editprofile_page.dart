import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  final int id;

  const EditProfilePage({super.key, required this.id});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>? userData;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _photoController;

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
    _photoController = TextEditingController();

    _fetchUserData();

    // Update preview saat isi photoController berubah
    _photoController.addListener(() {
      setState(() {}); // Refresh UI supaya avatar berubah
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app/user/${widget.id}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          userData = data['user'];
          _nameController.text = userData!['name'] ?? '';
          _emailController.text = userData!['email'] ?? '';
          _photoController.text = userData!['photo'] ?? '';
        } else {
          _error = 'User data not found';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Failed to fetch user data: $e';
    }

    setState(() {
      _isFetching = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app//user/${widget.id}',
      );

      Map<String, dynamic> bodyData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'photo': _photoController.text.trim(),
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
        final data = jsonDecode(response.body);
        if (data['message'] != null) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(data['message'])));
          }
          Navigator.pop(context, true);
        } else {
          setState(() {
            _error = 'Update failed';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection failed: $e';
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengambil gambar avatar berdasarkan input foto user,
  // fallback ke ui-avatars kalau kosong, atau asset default kalau nama juga kosong
  ImageProvider<Object> _getProfileImage() {
    final inputPhoto = _photoController.text.trim();

    if (inputPhoto.isNotEmpty) {
      // Cek apakah inputPhoto seperti URL (simple check)
      if (inputPhoto.startsWith('http') || inputPhoto.startsWith('https')) {
        return NetworkImage(inputPhoto);
      } else {
        // Bisa juga diubah ke AssetImage kalau input berupa path asset lokal
        return AssetImage(inputPhoto);
      }
    }

    // Kalau kosong, fallback ke avatar dari nama user
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final encodedName = Uri.encodeComponent(name);
      return NetworkImage(
        'https://ui-avatars.com/api/?name=$encodedName&background=0D8ABC&color=fff',
      );
    }

    // Default asset
    return const AssetImage('assets/images/profile.jpg');
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          title: const Text('Edit Profile'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        title: const Text('Edit Profile'),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Preview avatar profil berdasarkan input text foto
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade700, width: 3),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _getProfileImage(),
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField(label: 'Name', controller: _nameController),

            const SizedBox(height: 20),

            _buildTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // TextField untuk foto
            _buildTextField(
              label: 'Photo (URL or Asset)',
              controller: _photoController,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              label: 'New Password (leave blank to keep current)',
              controller: _passwordController,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
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
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
