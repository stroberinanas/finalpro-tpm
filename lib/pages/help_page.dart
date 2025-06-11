import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter untuk UI
// Mengimpor pustaka untuk menggunakan widget material dari Flutter

class HelpPage extends StatelessWidget {
  const HelpPage({super.key}); // Konstruktor untuk halaman HelpPage

  @override
  Widget build(BuildContext context) {
    // Mendefinisikan langkah-langkah tutorial untuk aplikasi
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'Browse Basecamps',
        'desc': 'Search for different basecamps to plan your next hike.',
        'icon': Icons.map, // Ikon untuk langkah ini
      },
      {
        'title': 'Check Your Gear',
        'desc': 'View a checklist of necessary gear for your hiking trip.',
        'icon': Icons.checklist_rtl, // Ikon untuk langkah ini
      },
      {
        'title': 'Know the Rules',
        'desc': 'Learn the dos and don’ts for a safe hike.',
        'icon': Icons.rule, // Ikon untuk langkah ini
      },
      {
        'title': 'View Location',
        'desc': 'Use Pos Location to find your way to the basecamp.',
        'icon': Icons.explore, // Ikon untuk langkah ini
      },
      {
        'title': 'SOS Alert',
        'desc': 'In case of an emergency, use the SOS feature for help.',
        'icon': Icons.sos, // Ikon untuk langkah ini
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Warna latar belakang AppBar
        title: const Text(
          'Help & Tutorial', // Judul halaman
          style: TextStyle(color: Colors.white), // Warna teks putih untuk judul
        ),
        centerTitle: true, // Menyelaraskan judul di tengah
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Memberikan padding pada halaman
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Menyusun elemen ke kiri
            children: [
              // Header dengan ilustrasi
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Colors
                                .green
                                .shade50, // Latar belakang warna hijau muda
                        shape: BoxShape.circle, // Membuat bentuk lingkaran
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(
                              0.12,
                            ), // Warna shadow
                            blurRadius: 16, // Tingkat blur shadow
                            offset: const Offset(0, 6), // Posisi shadow
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(
                        18,
                      ), // Padding di dalam lingkaran
                      child: const Icon(
                        Icons.help_outline, // Ikon untuk tombol bantuan
                        color: Colors.green, // Warna ikon
                        size: 48, // Ukuran ikon
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ), // Spasi vertikal antara ikon dan teks
                    const Text(
                      'How to Use This App', // Judul tutorial
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold, // Menebalkan teks
                        color: Colors.green, // Warna teks hijau
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18), // Spasi vertikal
              // Deskripsi aplikasi dalam card
              Card(
                color: Colors.green.shade50, // Warna latar belakang kartu
                elevation: 0, // Tidak ada bayangan
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Membuat sudut kartu melengkung
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0), // Padding di dalam kartu
                  child: Text(
                    "This app helps you navigate hiking trails, find basecamps, and more. "
                    "Follow the tutorial below to get started with our features.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87, // Warna teks
                      height: 1.4, // Jarak antar baris teks
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Spasi vertikal
              // Tutorial Steps dalam card
              ...steps
                  .map(
                    (step) => _buildStepCard(
                      step['title'], // Judul langkah
                      step['desc'], // Deskripsi langkah
                      step['icon'], // Ikon untuk langkah
                    ),
                  )
                  .toList(), // Menampilkan setiap langkah tutorial
            ],
          ),
        ),
      ),
    );
  }

  // Membuat widget card untuk setiap langkah tutorial
  Widget _buildStepCard(String title, String description, IconData icon) {
    return Card(
      color: Colors.white, // Warna latar belakang kartu
      elevation: 3, // Bayangan kartu
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ), // Margin vertikal antar kartu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ), // Sudut kartu melengkung
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ), // Padding di dalam kartu
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Menyusun elemen ke atas
          children: [
            // Menampilkan ikon dalam bentuk lingkaran
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100, // Latar belakang warna ikon
                shape: BoxShape.circle, // Bentuk lingkaran untuk ikon
              ),
              padding: const EdgeInsets.all(10), // Padding di dalam lingkaran
              child: Icon(
                icon,
                color: Colors.green,
                size: 28,
              ), // Menampilkan ikon
            ),
            const SizedBox(width: 16), // Spasi antara ikon dan teks
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Menyusun teks ke kiri
                children: [
                  Text(
                    title, // Menampilkan judul langkah
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold, // Menebalkan teks
                      color: Colors.green, // Warna teks hijau
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ), // Spasi vertikal antara judul dan deskripsi
                  Text(
                    description, // Menampilkan deskripsi langkah
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ), // Warna teks abu-abu
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
