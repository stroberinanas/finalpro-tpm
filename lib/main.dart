import 'package:finalpro/notification_service.dart'; // Mengimpor layanan notifikasi
import 'package:finalpro/pages/home_page.dart'; // Mengimpor widget HomePage
import 'package:finalpro/pages/login_page.dart'; // Mengimpor widget LoginPage
import 'package:flutter/material.dart'; // Mengimpor material design package untuk Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor SharedPreferences untuk menyimpan data lokal

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Memastikan bahwa binding widget Flutter sudah siap sebelum menjalankan kode lainnya
  await NotificationService().init(); // Inisialisasi layanan notifikasi
  runApp(const MyApp()); // Menjalankan aplikasi dengan widget utama MyApp
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  }); // Konstruktor untuk widget MyApp, menyertakan key sebagai parameter

  @override
  State<MyApp> createState() => _MyAppState(); // Membuat state untuk widget MyApp
}

class _MyAppState extends State<MyApp> {
  String?
  _email; // Menyimpan email pengguna yang diambil dari SharedPreferences
  String? _name; // Menyimpan nama pengguna yang diambil dari SharedPreferences
  bool _isLoading = true; // Menandakan apakah data sedang dimuat atau tidak

  @override
  void initState() {
    super.initState();
    _loadSession(); // Memanggil metode _loadSession() untuk memuat data session (login) pengguna
  }

  // Mengambil data pengguna (email dan nama) dari SharedPreferences
  Future<void> _loadSession() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences
    final email = prefs.getString(
      'email',
    ); // Mengambil email yang disimpan di SharedPreferences
    final name = prefs.getString(
      'name',
    ); // Mengambil nama yang disimpan di SharedPreferences

    setState(() {
      _email = email; // Menyimpan email ke dalam variabel _email
      _name = name; // Menyimpan nama ke dalam variabel _name
      _isLoading =
          false; // Menandakan bahwa data telah dimuat, sehingga tidak perlu loading lagi
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Jika data masih dimuat, tampilkan layar loading
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ), // Menampilkan CircularProgressIndicator
      );
    }

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ), // Mengatur tema aplikasi dengan primary swatch berwarna green
      home:
          (_email != null &&
                  _name !=
                      null) // Jika email dan nama ada (berarti pengguna sudah login)
              ? HomePage(
                name: _name!,
                email: _email!,
              ) // Arahkan ke HomePage dan kirim email serta nama pengguna
              : const LoginPage(), // Jika tidak ada email atau nama, arahkan ke LoginPage
      debugShowCheckedModeBanner:
          false, // Menonaktifkan banner debug di aplikasi
    );
  }
}
