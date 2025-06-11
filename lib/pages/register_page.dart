import 'dart:convert'; // Mengimpor pustaka dart:convert untuk menangani konversi JSON
import 'package:finalpro/pages/login_page.dart'; // Mengimpor halaman LoginPage
import 'package:flutter/material.dart'; // Mengimpor material design untuk UI Flutter
import 'package:http/http.dart'
    as http; // Mengimpor pustaka HTTP untuk melakukan request HTTP
// import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor pustaka SharedPreferences untuk penyimpanan data lokal

// Widget RegisterPage yang digunakan untuk tampilan halaman registrasi
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key}); // Konstruktor untuk widget RegisterPage

  @override
  State<RegisterPage> createState() => _RegisterPageState(); // Membuat state untuk RegisterPage
}

// State untuk widget RegisterPage
class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk menangkap input nama, email, dan password dari TextField
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State untuk toggle visibilitas password (untuk menampilkan/menyembunyikan password)
  bool _passwordVisible = false;

  // State untuk loading spinner saat proses register berjalan
  bool _isLoading = false;

  // String untuk menampung pesan error jika ada kesalahan
  String? _error;

  // Fungsi async untuk melakukan registrasi user ke server
  Future<void> _register() async {
    // Validasi sederhana: cek apakah semua field sudah diisi
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        _error = 'Please Fill All Fields'; // Pesan error jika ada field kosong
      });
      return; // Stop fungsi jika ada field yang belum lengkap diisi
    }

    setState(() {
      _isLoading = true; // Menampilkan loading spinner
      _error = null; // Reset pesan error
    });

    try {
      // URL endpoint backend untuk registrasi
      String url =
          "https://finalpro-api-1013759214686.us-central1.run.app/register";

      // Mengirim POST request dengan body JSON berisi data user
      var res = await http.post(
        Uri.parse(url), // Mengirimkan request POST ke URL register
        headers: {
          "Content-Type": "application/json",
        }, // Mengatur header request sebagai JSON
        body: jsonEncode({
          "name":
              nameController.text
                  .trim(), // Mengambil nama user dan menghapus spasi tambahan
          "email":
              emailController.text
                  .trim(), // Mengambil email user dan menghapus spasi tambahan
          "password":
              passwordController
                  .text, // Mengambil password user (tanpa di-trim)
        }),
      );

      // Mendecode response dari server yang berupa JSON
      var response = jsonDecode(res.body);

      print("Response: $response"); // Menampilkan response untuk debugging

      // Cek apakah registrasi berhasil berdasarkan response dari server
      if (response["success"] == true) {
        // Jika berhasil, tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );
        // Navigasi ke halaman login setelah registrasi sukses
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      } else if (response["message"] == "Email Already Exists") {
        // Jika email sudah terdaftar, tampilkan pesan error bahwa email sudah digunakan
        setState(() {
          _error = "Email Already Exists, Please Use Another Email";
        });
      } else {
        // Jika ada error lain dari backend, tampilkan pesan error yang sesuai
        setState(() {
          _error =
              response["message"] ??
              "Registration Failed"; // Menampilkan pesan error
        });
      }
    } catch (e) {
      // Tangani error jaringan atau exception lain
      setState(() {
        _error = "An error occurred. Please try again."; // Pesan error umum
      });
    } finally {
      // Setelah selesai, baik berhasil atau gagal, matikan loading spinner
      setState(() {
        _isLoading = false; // Menandakan bahwa loading telah selesai
      });
    }
  }

  // Dispose controller saat widget dihapus untuk mencegah memory leak
  @override
  void dispose() {
    nameController.dispose(); // Menghapus controller name saat widget dihapus
    emailController.dispose(); // Menghapus controller email saat widget dihapus
    passwordController
        .dispose(); // Menghapus controller password saat widget dihapus
    super.dispose(); // Memanggil dispose() dari superclass
  }

  // Fungsi pembantu untuk membuat InputDecoration dengan ikon hijau dan border hijau saat fokus
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label, // Label untuk input field
      prefixIcon: Icon(
        icon,
        color: Colors.green,
      ), // Ikon hijau di awal input field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Border melengkung
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ), // Border hijau saat input field fokus
      ),
      suffixIcon: suffixIcon, // Misalnya untuk ikon visibilitas password
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Latar belakang halaman registrasi berwarna putih
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding di sekitar konten
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center, // Menyusun konten secara vertikal di tengah
            children: [
              // Gambar ilustrasi register di atas
              Image.asset('assets/images/register.jpg', height: 200),
              const SizedBox(height: 10), // Jarak antara gambar dan teks
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

              // Input untuk Nama
              TextField(
                controller: nameController, // Controller untuk input nama
                decoration: _inputDecoration(label: 'Name', icon: Icons.person),
              ),

              const SizedBox(
                height: 20,
              ), // Jarak antara input nama dan input email
              // Input untuk Email dengan keyboard email
              TextField(
                controller: emailController, // Controller untuk input email
                keyboardType:
                    TextInputType
                        .emailAddress, // Mengatur keyboard untuk input email
                decoration: _inputDecoration(label: 'Email', icon: Icons.email),
              ),

              const SizedBox(
                height: 20,
              ), // Jarak antara input email dan input password
              // Input untuk Password dengan visibilitas toggle
              TextField(
                controller:
                    passwordController, // Controller untuk input password
                obscureText:
                    !_passwordVisible, // Menyembunyikan teks password jika _passwordVisible false
                decoration: _inputDecoration(
                  label: 'Password',
                  icon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons
                              .visibility, // Ikon untuk men-toggle visibilitas password
                      color: Colors.green,
                    ),
                    onPressed:
                        () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 30), // Jarak sebelum tombol Register
              // Jika ada error, tampilkan pesan error dengan warna merah
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              if (_error != null)
                const SizedBox(height: 15), // Jarak setelah pesan error
              // Tombol Register dengan lebar penuh
              SizedBox(
                width: double.infinity, // Tombol mengambil lebar penuh
                height: 50, // Tinggi tombol
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _register, // Nonaktifkan tombol jika sedang loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background tombol hijau
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Border tombol melengkung
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white, // Spinner putih saat loading
                          )
                          : const Text(
                            'Register',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                ),
              ),

              const SizedBox(
                height: 10,
              ), // Jarak sebelum tombol ke halaman Login
              // Tombol teks untuk navigasi ke halaman Login
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ), // Navigasi ke halaman Login
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: Color.fromARGB(
                      255,
                      115,
                      111,
                      111,
                    ), // Teks untuk link login
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
