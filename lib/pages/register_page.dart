import 'dart:convert';
import 'package:finalpro/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk input nama, email, dan password
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State untuk toggle visibilitas password
  bool _passwordVisible = false;

  // State untuk loading spinner saat proses register berjalan
  bool _isLoading = false;

  // String untuk menampung pesan error jika ada
  String? _error;

  // Fungsi async untuk register user ke server
  Future<void> _register() async {
    // Validasi sederhana: cek apakah semua field sudah diisi
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        _error = 'Please Fill All Fields'; // Pesan error jika ada field kosong
      });
      return; // Stop fungsi jika belum lengkap
    }

    setState(() {
      _isLoading = true; // Tampilkan loading spinner
      _error = null; // Reset pesan error
    });

    try {
      // URL endpoint backend untuk register (ganti sesuai alamat server kamu)
      String url = "http://172.16.81.177:5000/register";

      // Kirim POST request dengan body JSON berisi data user
      var res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(), // Nama user di-trim spasinya
          "email": emailController.text.trim(), // Email di-trim juga
          "password":
              passwordController.text, // Password (tanpa trim untuk aman)
        }),
      );

      // Decode response JSON dari backend
      var response = jsonDecode(res.body);

      // Jika backend berhasil membuat akun
      if (response["success"] == true) {
        // Tampilkan snackbar pemberitahuan sukses register
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );
        // Navigasi ke halaman login dan ganti halaman sekarang (pushReplacement)
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      } else if (response["message"] == "Email Already Exists") {
        // Jika email sudah dipakai, tampilkan error khusus
        setState(() {
          _error = "Email Already Exists, Please Use Another Email";
        });
      } else {
        // Jika ada error lain dari backend, tampilkan pesan errornya
        setState(() {
          _error = response["message"] ?? "Registration Failed";
        });
      }
    } catch (e) {
      // Jika terjadi error jaringan atau exception lain, tampilkan pesan umum
      setState(() {
        _error = "An error occurred. Please try again.";
      });
    } finally {
      // Setelah selesai, baik sukses atau gagal, matikan loading spinner
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Jangan lupa dispose controller saat widget hilang agar tidak bocor memori
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fungsi pembantu membuat InputDecoration dengan ikon hijau dan border hijau saat fokus
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label, // Label field input
      prefixIcon: Icon(icon, color: Colors.green), // Ikon hijau di depan
      border: OutlineInputBorder(
        // Border default melengkung
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        // Border hijau saat fokus
        borderRadius: BorderRadius.circular(12),
        // borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      suffixIcon: suffixIcon, // Misal tombol visibilitas password
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar putih
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding sisi-sisi
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Tengah secara vertikal
            children: [
              // Gambar ilustrasi register di atas
              Image.asset('assets/images/register.jpg', height: 200),
              const SizedBox(height: 10),

              // Judul halaman register
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const Text(
                'Lets Make Journey with L-Tex',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Input TextField Nama user
              TextField(
                controller: nameController,
                decoration: _inputDecoration(label: 'Name', icon: Icons.person),
              ),

              const SizedBox(height: 20),

              // Input TextField Email user dengan keyboard email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(label: 'Email', icon: Icons.email),
              ),

              const SizedBox(height: 20),

              // Input Password dengan visibilitas toggle
              TextField(
                controller: passwordController,
                obscureText: !_passwordVisible, // Sembunyikan jika false
                decoration: _inputDecoration(
                  label: 'Password',
                  icon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.green,
                    ),
                    onPressed:
                        () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Jika ada error, tampilkan teks merah
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              if (_error != null) const SizedBox(height: 15),

              // Tombol Register full lebar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _register, // disable saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background hijau
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Sudut melengkung
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // Spinner putih
                          : const Text(
                            'Register',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol teks untuk navigasi ke halaman Login
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: Color.fromARGB(255, 115, 111, 111),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
