import 'dart:convert'; // Mengimpor pustaka untuk konversi data JSON
import 'package:finalpro/pages/home_page.dart'; // Mengimpor halaman HomePage yang akan dibuka setelah login
import 'package:finalpro/pages/register_page.dart'; // Mengimpor halaman RegisterPage untuk pendaftaran akun baru
import 'package:flutter/material.dart'; // Mengimpor pustaka material design untuk komponen UI Flutter
import 'package:http/http.dart'
    as http; // Mengimpor pustaka HTTP untuk melakukan request ke server
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor pustaka untuk menyimpan data lokal menggunakan SharedPreferences

// Mendefinisikan widget LoginPage yang merupakan halaman login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Konstruktor untuk widget LoginPage

  @override
  State<LoginPage> createState() => _LoginPageState(); // Membuat state untuk widget LoginPage
}

// State untuk LoginPage
class _LoginPageState extends State<LoginPage> {
  // Controller untuk menangkap input email dan password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State untuk loading spinner, error message, dan visibilitas password
  bool _isLoading =
      false; // Menandakan apakah data sedang dimuat (loading) atau tidak
  String? _error; // Menyimpan pesan error jika terjadi kesalahan
  bool _passwordVisible =
      false; // Menyimpan status apakah password terlihat atau tidak

  // Simpan data session user ke SharedPreferences (storage lokal)
  Future<void> _saveSession(int id, String email, String name) async {
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences
    await prefs.setInt('id', id); // Menyimpan ID pengguna
    await prefs.setString('email', email); // Menyimpan email pengguna
    await prefs.setString('name', name); // Menyimpan nama pengguna
  }

  // Fungsi utama login, melakukan request POST ke backend
  Future<void> _login() async {
    setState(() {
      _isLoading =
          true; // Menandakan bahwa aplikasi sedang dalam status loading
      _error = null; // Reset pesan error
    });

    final url =
        "https://finalpro-api-1013759214686.us-central1.run.app/login"; // URL backend login
    try {
      final response = await http.post(
        Uri.parse(url), // Mengirimkan request POST ke URL login
        headers: {
          "Content-Type": "application/json",
        }, // Mengatur header request sebagai JSON
        body: jsonEncode({
          "email":
              _emailController.text
                  .trim(), // Mengambil email dari input dan menghapus spasi tambahan
          "password": _passwordController.text, // Mengambil password dari input
        }),
      );

      final data = jsonDecode(
        response.body,
      ); // Mengonversi response body dari JSON ke map

      print("Response: $data"); // Mencetak response dari server untuk debugging

      // Cek apakah login berhasil berdasarkan response dari server
      if (data['success'] == true) {
        final user = data['user']; // Mengambil data user dari response
        // Simpan session user ke lokal
        await _saveSession(user['id'], user['email'], user['name']);
        // Navigasi ke HomePage dan ganti halaman sekarang
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => HomePage(
                  name: user['name'],
                  email: user['email'],
                ), // Mengirim data user ke HomePage
          ),
        );
      } else {
        // Tampilkan pesan error dari backend jika login gagal
        setState(() {
          _error =
              data['message'] ??
              'Login failed'; // Menampilkan pesan error dari server
        });
      }
    } catch (e) {
      // Tangani error jaringan atau exception lain
      setState(() {
        _error =
            "An error occurred: $e"; // Menampilkan error jika terjadi masalah saat request
      });
    } finally {
      // Berhenti loading
      setState(() {
        _isLoading = false; // Menandakan bahwa loading telah selesai
      });
    }
  }

  // Dispose controller saat widget dihapus untuk mencegah memory leak
  @override
  void dispose() {
    _emailController
        .dispose(); // Menghapus controller untuk email saat widget dihapus
    _passwordController
        .dispose(); // Menghapus controller untuk password saat widget dihapus
    super.dispose(); // Memanggil dispose() dari superclass
  }

  // Build UI login page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // Warna latar belakang halaman login
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            24.0,
          ), // Padding untuk konten di dalam halaman
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center, // Menyusun konten secara vertikal di tengah
            children: [
              // Gambar login di atas
              Image.asset(
                'assets/images/login.jpg',
                height: 300,
              ), // Gambar logo/login halaman

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
                controller:
                    _emailController, // Menghubungkan dengan controller email
                keyboardType:
                    TextInputType
                        .emailAddress, // Mengatur keyboard untuk input email
                decoration: InputDecoration(
                  labelText: 'Email', // Label untuk input email
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.green,
                  ), // Ikon email di kiri input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Mengatur border input
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Input Password dengan toggle visibilitas
              TextField(
                controller:
                    _passwordController, // Menghubungkan dengan controller password
                obscureText:
                    !_passwordVisible, // Menyembunyikan teks password jika _passwordVisible false
                decoration: InputDecoration(
                  labelText: 'Password', // Label untuk input password
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.green,
                  ), // Ikon gembok di kiri input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Mengatur border input
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility, // Toggle antara ikon visibility
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible =
                            !_passwordVisible; // Mengubah visibilitas password
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Jika ada error, tampilkan dengan warna merah
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ), // Menampilkan pesan error jika ada

              const SizedBox(height: 20),

              // Tombol Login dengan full lebar, disabled saat loading
              SizedBox(
                width: double.infinity, // Tombol mengambil lebar penuh
                height: 50, // Mengatur tinggi tombol
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _login, // Nonaktifkan tombol saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background tombol hijau
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Mengatur border tombol
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.green,
                          ) // Menampilkan loading indicator
                          : const Text(
                            'Login',
                            style: TextStyle(
                              color: Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ), // Warna teks putih
                              fontSize: 18, // Ukuran font teks
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol ke halaman Register
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ), // Navigasi ke halaman Register
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: Color.fromARGB(255, 100, 94, 94),
                  ), // Teks untuk link pendaftaran
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
