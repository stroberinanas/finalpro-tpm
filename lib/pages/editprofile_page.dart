import 'dart:convert'; // Mengimpor pustaka untuk encoding dan decoding data JSON
import 'dart:io'; // Mengimpor pustaka untuk mengakses sistem file, seperti File
import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter untuk membuat UI
import 'package:http/http.dart'
    as http; // Mengimpor pustaka HTTP untuk melakukan request ke server
import 'package:image_picker/image_picker.dart'; // Mengimpor pustaka untuk memilih gambar dari galeri atau kamera

// Halaman untuk mengedit profil pengguna
class EditProfilePage extends StatefulWidget {
  final int id; // ID pengguna yang ingin diedit

  const EditProfilePage({
    super.key,
    required this.id,
  }); // Konstruktor halaman yang menerima ID pengguna

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>?
  userData; // Menyimpan data pengguna yang diambil dari server
  File? _imageFile; // Menyimpan file gambar profil baru yang dipilih pengguna
  final ImagePicker _picker = ImagePicker(); // Objek untuk memilih gambar
  String? _uploadedImageUrl; // URL gambar yang diunggah

  late TextEditingController
  _nameController; // Controller untuk teks input nama
  late TextEditingController
  _emailController; // Controller untuk teks input email
  late TextEditingController
  _passwordController; // Controller untuk teks input password

  bool _isLoading = false; // Menandakan apakah proses sedang berlangsung
  String? _error; // Menyimpan pesan error jika ada
  bool _isFetching = true; // Menandakan apakah data pengguna sedang diambil
  bool _passwordVisible =
      false; // Menandakan apakah password terlihat atau tidak

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller untuk inputan teks
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _fetchUserData(); // Ambil data pengguna saat halaman diinisialisasi
  }

  @override
  void dispose() {
    // Menutup controller ketika halaman dibuang
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // Memilih gambar dari galeri
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(
          pickedFile.path,
        ); // Menyimpan path gambar yang dipilih
      });
    }
  }

  // Fetch data pengguna dari API berdasarkan ID pengguna
  Future<void> _fetchUserData() async {
    try {
      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app/user/${widget.id}', // URL API untuk mengambil data pengguna
      );
      final response = await http.get(
        url,
      ); // Mengirimkan request GET untuk mengambil data pengguna

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decode JSON response
        if (data['success'] == true && data['user'] != null) {
          if (mounted) {
            setState(() {
              userData = data['user']; // Menyimpan data pengguna ke state
              _nameController.text =
                  userData!['name'] ?? ''; // Menampilkan nama pengguna
              _emailController.text =
                  userData!['email'] ?? ''; // Menampilkan email pengguna
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _error =
                  'User data not found'; // Menampilkan error jika data pengguna tidak ditemukan
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error =
                'Server error: ${response.statusCode}'; // Menampilkan error server jika status code tidak 200
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Failed to fetch user data: $e'; // Menampilkan error jika request gagal
        });
      }
    }
  }

  // Method untuk mengunggah gambar ke server
  Future<void> _uploadImage(int userId) async {
    if (_imageFile == null)
      return; // Jika tidak ada gambar yang dipilih, keluar dari fungsi

    final url = Uri.parse(
      'https://finalpro-api-1013759214686.us-central1.run.app/user/$userId/upload-photo', // URL API untuk mengunggah gambar
    );

    var request = http.MultipartRequest(
      'POST',
      url,
    ); // Membuat request multipart
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        _imageFile!.path,
      ), // Menambahkan file gambar ke request
    );
    var response = await request.send(); // Mengirimkan request

    if (response.statusCode == 200) {
      // Jika berhasil, buat timestamp untuk menghindari cache
      setState(() {
        _uploadedImageUrl =
            'https://finalpro-api-1013759214686.us-central1.run.app${userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}'; // Menyimpan URL gambar yang diunggah
        _imageFile = null; // Reset file gambar lokal setelah diunggah
      });
    } else {
      throw Exception(
        'Failed to upload image',
      ); // Menangani error jika upload gagal
    }
  }

  // Method untuk menyimpan data profil
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true; // Menandakan bahwa data sedang disimpan
      _error = null; // Menghapus pesan error
    });

    try {
      final url = Uri.parse(
        'https://finalpro-api-1013759214686.us-central1.run.app/user/${widget.id}', // URL API untuk menyimpan data pengguna
      );

      Map<String, dynamic> bodyData = {
        'name': _nameController.text.trim(), // Mengambil nama dari controller
        'email':
            _emailController.text.trim(), // Mengambil email dari controller
      };

      // Jika password tidak kosong, tambahkan password baru ke body data
      if (_passwordController.text.trim().isNotEmpty) {
        bodyData['password'] = _passwordController.text.trim();
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        }, // Menetapkan header untuk tipe konten JSON
        body: jsonEncode(bodyData), // Mengirimkan body data dalam format JSON
      );

      if (response.statusCode == 200) {
        // Jika berhasil, unggah gambar jika ada
        if (_imageFile != null) {
          await _uploadImage(widget.id);
        }
        if (mounted) {
          setState(() {
            _isLoading = false; // Set loading false setelah proses selesai
          });
          Navigator.pop(
            context,
            true,
          ); // Kembali ke halaman sebelumnya dan mengirimkan hasil berhasil
        }
      } else {
        if (mounted) {
          setState(() {
            _error =
                'Server error: ${response.statusCode}'; // Menampilkan error jika status code tidak 200
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Connection failed: $e'; // Menampilkan error jika request gagal
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
          controller: controller, // Menghubungkan dengan controller
          obscureText: obscureText, // Menyembunyikan teks untuk password
          keyboardType:
              keyboardType, // Menetapkan tipe keyboard (misalnya email)
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
            suffixIcon: suffixIcon, // Ikon di akhir input field
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
        _uploadedImageUrl!, // Jika ada gambar yang sudah diunggah
      );
    }

    // Cek apakah ada foto dari backend user
    if (userData != null && userData!['photo'] != null) {
      return NetworkImage(
        'https://finalpro-api-1013759214686.us-central1.run.app${userData!['photo']}?t=${DateTime.now().millisecondsSinceEpoch}',
      ); // Mengambil gambar dari backend
    }

    // Fallback ke gambar profil default
    return const AssetImage(
      'assets/images/profile.jpg', // Gambar profil default
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        backgroundColor: Colors.green, // Latar belakang hijau untuk AppBar
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white), // Judul dengan teks putih
        ),
        elevation: 0, // Menghilangkan bayangan pada AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Tombol untuk kembali
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
                    : const Icon(Icons.check, color: Colors.black),
            onPressed:
                _isLoading
                    ? null
                    : _saveProfile, // Menyimpan profil ketika tidak dalam keadaan loading
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
