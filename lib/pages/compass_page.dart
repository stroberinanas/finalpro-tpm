import 'dart:math'
    as math; // Mengimpor pustaka matematika untuk menghitung sudut, rotasi, dan lainnya
import 'dart:async'; // Mengimpor pustaka untuk menangani Stream dan Subscription
import 'package:flutter/material.dart'; // Mengimpor Flutter untuk membuat UI
import 'package:flutter_compass/flutter_compass.dart'; // Mengimpor pustaka untuk mendapatkan data kompas
import 'package:location/location.dart'; // Mengimpor pustaka untuk mengakses data lokasi

// Widget utama untuk halaman kompas
class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double? _heading; // Menyimpan nilai heading kompas (arah mata angin)
  StreamSubscription? _compassSubscription; // Untuk berlangganan data kompas

  final Location _location = Location(); // Instansi untuk mengakses data lokasi

  double? _latitude; // Menyimpan latitude pengguna
  double? _longitude; // Menyimpan longitude pengguna
  double? _elevation; // Menyimpan elevasi (ketinggian) pengguna

  @override
  void initState() {
    super.initState();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      setState(() {
        _heading =
            event.heading; // Memperbarui heading kompas saat data baru diterima
      });
    });
    _requestLocationPermissionAndListen(); // Meminta izin lokasi dan mulai mendengarkan lokasi
  }

  // Fungsi untuk meminta izin lokasi dan mulai mendengarkan perubahan lokasi
  void _requestLocationPermissionAndListen() async {
    bool serviceEnabled =
        await _location
            .serviceEnabled(); // Memeriksa apakah layanan lokasi aktif
    if (!serviceEnabled) {
      serviceEnabled =
          await _location
              .requestService(); // Meminta pengguna untuk mengaktifkan layanan lokasi
      if (!serviceEnabled)
        return; // Jika layanan lokasi tidak diaktifkan, keluar
    }

    PermissionStatus permissionGranted =
        await _location.hasPermission(); // Memeriksa izin lokasi
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted =
          await _location
              .requestPermission(); // Meminta izin lokasi jika belum diberikan
      if (permissionGranted != PermissionStatus.granted)
        return; // Jika izin ditolak, keluar
    }

    // Mendengarkan perubahan lokasi dan memperbarui state
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _latitude = currentLocation.latitude; // Memperbarui latitude
        _longitude = currentLocation.longitude; // Memperbarui longitude
        _elevation = currentLocation.altitude; // Memperbarui elevasi
      });
    });
  }

  @override
  void dispose() {
    _compassSubscription
        ?.cancel(); // Membatalkan langganan kompas saat widget dihapus
    super.dispose();
  }

  // Fungsi untuk menentukan arah berdasarkan nilai heading
  String _directionLabel(double direction) {
    if (direction >= 337.5 || direction < 22.5) return "NORTH"; // 0-22.5°
    if (direction >= 22.5 && direction < 67.5) return "NORTHEAST"; // 22.5-67.5°
    if (direction >= 67.5 && direction < 112.5) return "EAST"; // 67.5-112.5°
    if (direction >= 112.5 && direction < 157.5)
      return "SOUTHEAST"; // 112.5-157.5°
    if (direction >= 157.5 && direction < 202.5) return "SOUTH"; // 157.5-202.5°
    if (direction >= 202.5 && direction < 247.5)
      return "SOUTHWEST"; // 202.5-247.5°
    if (direction >= 247.5 && direction < 292.5) return "WEST"; // 247.5-292.5°
    if (direction >= 292.5 && direction < 337.5)
      return "NORTHWEST"; // 292.5-337.5°
    return "";
  }

  // Fungsi untuk memformat koordinat menjadi format derajat, menit, detik
  String _formatCoordinate(double? coord, bool isLatitude) {
    if (coord == null) return "..."; // Jika koordinat null, kembalikan "..."
    final degrees = coord.abs().floor(); // Derajat
    final minutes = ((coord.abs() - degrees) * 60).floor(); // Menit
    final seconds =
        (((coord.abs() - degrees) * 60 - minutes) * 60).floor(); // Detik
    final direction =
        isLatitude
            ? (coord >= 0 ? "N" : "S")
            : (coord >= 0 ? "E" : "W"); // Arah N/S atau E/W
    return "$degrees°$minutes'${seconds}\" $direction"; // Mengembalikan format koordinat
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading ?? 0; // Jika heading null, set ke 0
    final directionLabel = _directionLabel(heading); // Mendapatkan label arah

    final latitudeStr = _formatCoordinate(_latitude, true); // Format latitude
    final longitudeStr = _formatCoordinate(
      _longitude,
      false,
    ); // Format longitude
    final elevationStr =
        _elevation != null
            ? "${_elevation!.toStringAsFixed(0)} M" // Format elevasi jika ada
            : "Elevation Not Available"; // Jika elevasi tidak tersedia

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang halaman
      appBar: AppBar(
        backgroundColor: Colors.green, // Warna latar belakang AppBar
        elevation: 0,
        title: const Text(
          'Compass Page', // Judul halaman
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Menyelaraskan judul di tengah
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header ilustrasi kompas
                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 10),
                  child: Column(children: [const SizedBox(height: 8)]),
                ),
                // Kompas dengan shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(180),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.13),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: const Size(300, 300), // Ukuran kompas
                    painter: _ModernCompassPainter(
                      heading,
                    ), // Menggambar kompas
                  ),
                ),
                const SizedBox(height: 36),
                // Arah dan derajat
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        directionLabel, // Menampilkan arah
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${heading.toStringAsFixed(1)}°", // Menampilkan derajat heading
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Info koordinat dan elevasi dalam card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
                    color: Colors.green.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          _buildInfoRowWithIcon(
                            Icons.my_location,
                            "LATITUDE",
                            latitudeStr, // Menampilkan latitude
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRowWithIcon(
                            Icons.explore,
                            "LONGITUDE",
                            longitudeStr, // Menampilkan longitude
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRowWithIcon(
                            Icons.terrain,
                            "ELEVATION",
                            elevationStr, // Menampilkan elevasi
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membangun baris informasi dengan ikon
  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22), // Menampilkan ikon
        const SizedBox(width: 10),
        Text(
          label, // Label (misalnya: LATITUDE)
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value, // Menampilkan nilai (misalnya: 12°34'56" N)
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ModernCompassPainter extends CustomPainter {
  final double heading;

  _ModernCompassPainter(this.heading);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    ); // Titik tengah kompas
    final radius = math.min(size.width / 2, size.height / 2); // Radius kompas

    // Kompas utama (lingkaran)
    final circlePaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill; // Menggambar lingkaran
    canvas.drawCircle(center, radius - 10, circlePaint);

    // Menyimpan dan merotasi kanvas untuk menggambar tanda arah
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180); // Rotasi berdasarkan heading

    final tickPaintSmall =
        Paint()
          ..color = Colors.grey[600]!
          ..strokeWidth = 1.5; // Tanda arah kecil
    final tickPaintMain =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 1.5; // Tanda arah utama (lebih besar)

    for (int i = 0; i < 360; i += 6) {
      final isMainTick = (i % 30 == 0); // Tanda arah utama setiap 30°
      final tickLength = isMainTick ? 20.0 : 10.0; // Panjang tanda arah
      final paint =
          isMainTick
              ? tickPaintMain
              : tickPaintSmall; // Pilih cat berdasarkan jenis tanda arah

      final angle = (i - 90) * math.pi / 180; // Menghitung sudut
      final start = Offset(
        (radius - tickLength - 20) * math.cos(angle),
        (radius - tickLength - 20) * math.sin(angle),
      );
      final end = Offset(
        (radius - 20) * math.cos(angle),
        (radius - 20) * math.sin(angle),
      );

      canvas.drawLine(start, end, paint); // Menggambar garis tanda arah

      // Menambahkan nomor derajat untuk tanda arah utama
      if (isMainTick) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i', // Menampilkan angka derajat
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final textOffset = Offset(
          (radius - 45) * math.cos(angle) - textPainter.width / 2,
          (radius - 45) * math.sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // Menambahkan huruf arah (N, E, S, W)
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];
    final directionTextStyle = TextStyle(
      color: Colors.green,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < directions.length; i++) {
      final angle = (angles[i] - 90) * math.pi / 180;
      final textPainter = TextPainter(
        text: TextSpan(text: directions[i], style: directionTextStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final pos = Offset(
        (radius - 70) * math.cos(angle) - textPainter.width / 2,
        (radius - 70) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, pos);
    }

    canvas.restore(); // Mengembalikan kanvas ke posisi semula

    // Menggambar jarum kompas (needle)
    final needleLength = radius * 0.6;
    final needlePaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.red, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromPoints(
              Offset(center.dx - 8, center.dy - needleLength),
              Offset(center.dx + 8, center.dy + needleLength),
            ),
          )
          ..style = PaintingStyle.fill;

    Path needlePath = Path();
    needlePath.moveTo(center.dx, center.dy - needleLength);
    needlePath.lineTo(center.dx - 8, center.dy);
    needlePath.lineTo(center.dx, center.dy + needleLength * 0.3);
    needlePath.lineTo(center.dx + 8, center.dy);
    needlePath.close();
    canvas.drawPath(needlePath, needlePaint); // Menggambar jarum kompas
  }

  @override
  bool shouldRepaint(covariant _ModernCompassPainter oldDelegate) {
    return oldDelegate.heading !=
        heading; // Menggambar ulang jika heading berubah
  }
}
