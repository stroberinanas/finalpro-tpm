import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Mengimpor pustaka untuk notifikasi lokal pada aplikasi Flutter.

class NotificationService {
  static final _plugin =
      FlutterLocalNotificationsPlugin(); // Membuat instance dari FlutterLocalNotificationsPlugin untuk mengelola notifikasi lokal.

  // Method untuk inisialisasi pengaturan notifikasi
  Future<void> init() async {
    // Mengonfigurasi pengaturan Android untuk inisialisasi notifikasi
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher', // Menentukan ikon aplikasi yang akan digunakan untuk notifikasi
    );

    // Menentukan pengaturan inisialisasi notifikasi secara keseluruhan
    const settings = InitializationSettings(android: androidSettings);

    // Melakukan inisialisasi plugin notifikasi dengan pengaturan yang sudah ditentukan
    await _plugin.initialize(settings);
  }

  // Method untuk menampilkan notifikasi dengan judul dan pesan
  Future<void> show(String title, String body) async {
    print("abc"); // Debug print untuk memastikan fungsi ini dipanggil

    // Menentukan detail notifikasi untuk Android
    const androidDetails = AndroidNotificationDetails(
      'nearby_events', // ID kanal notifikasi
      'Nearby Events', // Nama kanal notifikasi
      importance: Importance.max, // Menentukan tingkat kepentingan notifikasi
      priority: Priority.high, // Menentukan prioritas notifikasi
    );

    // Menyusun objek detail notifikasi
    const notifDetails = NotificationDetails(android: androidDetails);

    // Menampilkan notifikasi dengan ID 0, judul, dan isi pesan
    await _plugin.show(0, title, body, notifDetails);
  }
}
