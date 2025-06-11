import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold adalah struktur dasar halaman yang mencakup app bar dan body
    return Scaffold(
      // AppBar untuk bagian atas halaman, termasuk judul dan styling
      appBar: AppBar(
        backgroundColor: Colors.green, // Menetapkan warna latar belakang AppBar
        title: const Text(
          'About Lawu',
          style: TextStyle(color: Colors.white),
        ), // Judul di AppBar
        centerTitle: true, // Menengahkan judul
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Body halaman yang bisa di-scroll, dilapisi padding
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Padding di seluruh body
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Menyusun elemen di sebelah kiri
          children: [
            // Foto Gunung Lawu dengan shadow dan gradient overlay
            Center(
              child: Stack(
                children: [
                  // Container berisi gambar Gunung Lawu dengan border radius dan shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        18,
                      ), // Radius sudut gambar
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        18,
                      ), // Memotong gambar dengan border radius
                      child: Image.network(
                        'https://shelterjelajah.com/wp-content/uploads/2023/03/Jalur-Pendakian-Gunung-Lawu.jpg', // URL gambar Gunung Lawu
                        height: 220, // Menetapkan tinggi gambar
                        width: double.infinity, // Menetapkan lebar gambar penuh
                        fit:
                            BoxFit
                                .cover, // Gambar akan menutupi area yang tersedia
                      ),
                    ),
                  ),
                  // Overlay gradient untuk menambah efek transisi warna
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter, // Mulai dari bawah
                          end: Alignment.topCenter, // Akhir di atas
                          colors: [
                            Colors.black.withOpacity(
                              0.25,
                            ), // Gradient warna hitam transparan
                            Colors.transparent, // Transparansi menuju atas
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Menambahkan teks di atas gambar, menggunakan posisi tertentu
                  Positioned(
                    left: 16, // Posisi kiri dari teks
                    bottom: 16, // Posisi bawah dari teks
                    child: Text(
                      'Gunung Lawu', // Teks yang ditampilkan
                      style: TextStyle(
                        color: Colors.white, // Warna teks putih
                        fontWeight: FontWeight.bold, // Teks tebal
                        fontSize: 22, // Ukuran font
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(
                              0.4,
                            ), // Efek bayangan untuk teks
                            blurRadius: 8, // Jarak blur bayangan
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18), // Jarak antar elemen
            // Deskripsi singkat tentang Gunung Lawu dalam bentuk kartu
            Card(
              color: Colors.green.shade50, // Warna latar belakang kartu
              elevation: 0, // Tanpa bayangan pada kartu
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ), // Sudut melengkung kartu
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0), // Padding dalam kartu
                child: Text(
                  'Gunung Lawu adalah gunung berapi yang terletak di perbatasan Jawa Tengah dan Jawa Timur. Dikenal dengan keindahan alam, jalur pendakian yang menantang, serta nilai sejarah dan spiritual yang tinggi.',
                  style: TextStyle(
                    fontSize: 15, // Ukuran font
                    color: Colors.green.shade900, // Warna teks
                    height: 1.4, // Jarak antar baris
                  ),
                  textAlign:
                      TextAlign.justify, // Menyusun teks dengan rata kanan kiri
                ),
              ),
            ),

            const SizedBox(height: 18), // Jarak antar elemen
            // Info baris dengan icon dan teks, menggunakan method helper _buildInfoRow
            _buildInfoRow(
              Icons.height, // Ikon tinggi
              'Elevation: 3,265 m (10,712 ft)', // Teks info
              Colors.green.shade700, // Warna ikon
              iconSize: 28, // Ukuran ikon
            ),
            const SizedBox(height: 10), // Jarak antar elemen
            _buildInfoRow(
              Icons.arrow_upward, // Ikon ketinggian
              'Prominence: 3,118 m', // Teks info
              Colors.blue.shade700, // Warna ikon
              iconSize: 28, // Ukuran ikon
            ),
            const SizedBox(height: 10), // Jarak antar elemen
            _buildInfoRow(
              Icons.category, // Ikon kategori
              'Category: Difficult', // Teks info
              Colors.orange.shade700, // Warna ikon
              iconSize: 28, // Ukuran ikon
            ),
            const SizedBox(height: 10), // Jarak antar elemen
            _buildInfoRow(
              Icons.location_on, // Ikon lokasi
              'Province: East Java & Central Java', // Teks info
              Colors.purple.shade700, // Warna ikon
              iconSize: 28, // Ukuran ikon
            ),
            const SizedBox(height: 10), // Jarak antar elemen
            _buildInfoRow(
              Icons.warning_amber_rounded, // Ikon peringatan
              'Eruptions: 1885', // Teks info
              Colors.red.shade700, // Warna ikon
              iconSize: 28, // Ukuran ikon
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membuat baris dengan ikon dan teks
  Widget _buildInfoRow(
    IconData icon, // Ikon yang digunakan
    String text, // Teks yang ditampilkan
    Color iconColor, { // Warna ikon
    double iconSize = 20, // Ukuran ikon, default 20
  }) {
    return Card(
      elevation: 2, // Efek bayangan pada kartu
      color: Colors.white, // Warna latar belakang kartu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Sudut kartu
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 12.0,
        ), // Padding dalam kartu
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: iconSize), // Menampilkan ikon
            const SizedBox(width: 18), // Jarak antara ikon dan teks
            Expanded(
              child: Text(
                text, // Teks yang ditampilkan
                style: const TextStyle(
                  fontSize: 16, // Ukuran font
                  fontWeight: FontWeight.w600, // Ketebalan font
                  color: Colors.black87, // Warna teks
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
