import 'dart:convert';
import 'package:finalpro/pages/home_page.dart';
import 'package:finalpro/pages/register_page.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk menangkap input email dan password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State untuk loading spinner, error message, dan visibilitas password
  bool _isLoading = false;
  String? _error;
  bool _passwordVisible = false;

  // Simpan data session user ke SharedPreferences (storage lokal)
  Future<void> _saveSession(int id, String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', id);
    await prefs.setString('email', email);
    await prefs.setString('name', name);
  }

  // Fungsi utama login, melakukan request POST ke backend
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Mulai loading
      _error = null; // Reset error
    });

    final url =
        "http://10.0.2.2:5000/login"; // URL backend login (10.0.2.2 untuk emulator)
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      print("Response: $data");

      // Cek apakah login berhasil
      if (data['success'] == true) {
        final user = data['user'];
        // Simpan session user ke lokal
        await _saveSession(user['id'], user['email'], user['name']);
        // Navigasi ke HomePage dan ganti halaman sekarang
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(name: user['name'], email: user['email']),
          ),
        );
      } else {
        // Tampilkan pesan error dari backend jika gagal login
        setState(() {
          _error = data['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      // Tangani error jaringan / exception lain
      setState(() {
        _error = "An error occurred: $e";
      });
    } finally {
      // Berhenti loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Dispose controller saat widget dihapus untuk mencegah memory leak
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Build UI login page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar login di atas
              Image.asset('assets/images/login.jpg', height: 300),

              const SizedBox(height: 5),

              // Judul sambutan
              const Text(
                'Login With Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Welcome to L-Tex',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),
              // Input Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Input Password dengan toggle visibilitas
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Jika ada error, tampilkan dengan warna merah
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),
              // Tombol Login dengan full lebar, disabled saat loading
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // background putih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.green)
                          : const Text(
                            'Login',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 18,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol ke halaman Register
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Color.fromARGB(255, 100, 94, 94)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
