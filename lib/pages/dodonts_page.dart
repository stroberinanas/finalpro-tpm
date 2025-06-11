import 'package:flutter/material.dart'; // Mengimpor paket Flutter untuk membuat UI

// Halaman Do's and Don'ts untuk hiking
class DoDontsPage extends StatelessWidget {
  const DoDontsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Mengatur warna latar belakang AppBar
        title: const Text(
          'Do\'s and Don\'ts for Hiking', // Judul halaman dengan teks berwarna putih
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Menyelaraskan judul di tengah
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding di sekitar konten
        child: SingleChildScrollView(
          // Membuat kolom dengan scroll jika konten terlalu panjang
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Menyusun elemen-elemen di kolom
            children: [
              // Header dengan ilustrasi
              Center(
                child: Column(
                  children: [
                    // Ilustrasi gambar di dalam lingkaran dengan shadow
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50, // Warna latar belakang
                        shape: BoxShape.circle, // Bentuk lingkaran
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(
                              0.12,
                            ), // Warna shadow
                            blurRadius: 16, // Blur radius shadow
                            offset: const Offset(0, 6), // Posisi shadow
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(
                        18,
                      ), // Padding di dalam lingkaran
                      child: const Icon(
                        Icons.terrain, // Ikon gunung
                        color: Colors.green, // Warna ikon hijau
                        size: 48, // Ukuran ikon
                      ),
                    ),
                    const SizedBox(height: 10), // Spasi antara gambar dan teks
                    const Text(
                      'Hiking Do\'s & Don\'ts', // Teks judul untuk bagian ini
                      style: TextStyle(
                        fontSize: 20, // Ukuran font
                        fontWeight: FontWeight.bold, // Menebalkan teks
                        color: Colors.green, // Warna teks hijau
                      ),
                    ),
                    const SizedBox(height: 6), // Spasi
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ), // Spasi untuk pemisah antara header dan daftar
              // Card Do's
              Text(
                'Do\'s', // Teks untuk bagian Do's
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700, // Warna hijau untuk judul
                ),
              ),
              const SizedBox(height: 10), // Spasi
              // Membuat daftar item Do's
              ..._buildListCards(
                [
                  ['Do exercise before the hike', '🏃‍♂️'],
                  ['Do drink enough water during the hike', '💧'],
                  ['Do wear appropriate clothing and sunscreen', '☀️'],
                  ['Do take breaks and enjoy the view', '⛰️'],
                  ['Do wear comfortable footwear', '👟'],
                ],
                Colors.green.shade100, // Warna latar belakang card
                Colors.green, // Warna ikon
              ),
              const SizedBox(
                height: 28,
              ), // Spasi untuk pemisah antara Do's dan Don'ts
              // Card Don'ts
              Text(
                'Don\'ts', // Teks untuk bagian Don\'ts
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700, // Warna merah untuk judul
                ),
              ),
              const SizedBox(height: 10), // Spasi
              // Membuat daftar item Don'ts
              ..._buildListCards(
                [
                  ['Don\'t litter', '❌'],
                  ['Don\'t cut the hiking trail', '🚫'],
                  ['Don\'t ignore safety', '⚠️'],
                  ['Don\'t hike without proper physical preparation', '💪'],
                  ['Don\'t bring excessive items', '🎒'],
                ],
                Colors.red.shade100, // Warna latar belakang card
                Colors.red, // Warna ikon
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method untuk membangun daftar card yang cantik untuk Do's dan Don'ts
  List<Widget> _buildListCards(
    List<List<String>>
    data, // Data yang berisi teks dan ikon untuk Do's atau Don'ts
    Color cardColor, // Warna latar belakang card
    Color iconColor, // Warna ikon
  ) {
    return data.map((row) {
      return Card(
        color: cardColor, // Warna latar belakang card
        elevation: 3, // Efek elevasi pada card
        margin: const EdgeInsets.symmetric(vertical: 7), // Margin antara card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ), // Sudut melengkung
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 14,
          ), // Padding dalam card
          child: Row(
            children: [
              Text(
                row[1],
                style: TextStyle(fontSize: 28, color: iconColor),
              ), // Menampilkan ikon
              const SizedBox(width: 18), // Spasi antara ikon dan teks
              Expanded(
                child: Text(
                  row[0], // Teks untuk Do atau Don't
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500, // Mengatur ketebalan teks
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(); // Mengembalikan daftar card
  }
}
