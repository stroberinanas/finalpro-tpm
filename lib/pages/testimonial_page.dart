import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter untuk UI

class TestimonialPage extends StatelessWidget {
  const TestimonialPage({
    super.key,
  }); // Konstruktor untuk halaman TestimonialPage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Latar belakang AppBar berwarna hijau
        title: const Text(
          'Testimonial',
          style: TextStyle(color: Colors.white),
        ), // Judul halaman "Testimonial" dengan teks putih
        centerTitle: true, // Menyelaraskan judul ke tengah
        elevation: 0, // Menghilangkan bayangan pada AppBar
      ),
      backgroundColor: const Color(
        0xFFF5F9F8,
      ), // Latar belakang halaman dengan warna soft
      body: SingleChildScrollView(
        // Membuat tampilan scrollable pada body
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ), // Memberikan padding pada konten halaman
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Menyusun elemen-elemen di tengah
            children: [
              // Header dengan ilustrasi
              Center(
                child: Column(
                  children: [
                    // Membuat lingkaran dengan ikon di dalamnya
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Colors
                                .green
                                .shade50, // Latar belakang lingkaran dengan hijau muda
                        shape: BoxShape.circle, // Bentuk lingkaran
                        boxShadow: [
                          // Menambahkan bayangan pada lingkaran
                          BoxShadow(
                            color: Colors.green.withOpacity(
                              0.10,
                            ), // Warna bayangan hijau transparan
                            blurRadius: 16, // Tingkat kehalusan bayangan
                            offset: const Offset(0, 6), // Posisi bayangan
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(
                        18,
                      ), // Padding dalam lingkaran
                      child: const Icon(
                        Icons.reviews_rounded, // Ikon testimoni
                        color: Colors.green, // Warna ikon hijau
                        size: 48, // Ukuran ikon
                      ),
                    ),
                    const SizedBox(height: 12), // Memberikan jarak vertikal
                    const Text(
                      'Semester 6 Mobile App Testimonial', // Judul testimoni
                      style: TextStyle(
                        fontSize: 20, // Ukuran font judul
                        fontWeight: FontWeight.bold, // Menebalkan font
                        color: Colors.green, // Warna teks hijau
                      ),
                      textAlign:
                          TextAlign.center, // Menyelaraskan teks ke tengah
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Spasi vertikal
              // Card testimoni
              Card(
                color: Colors.white, // Warna latar belakang kartu putih
                elevation: 3, // Menambahkan bayangan pada kartu
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Membuat sudut kartu melengkung
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24, // Padding vertikal pada kartu
                    horizontal: 18, // Padding horizontal pada kartu
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Menyusun elemen di tengah
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center, // Menyusun elemen di tengah
                        children: [
                          // Membuat empat bintang penuh
                          ...List.generate(
                            4,
                            (i) => const Icon(
                              Icons.star,
                              color: Colors.amber, // Warna bintang kuning
                              size: 28, // Ukuran bintang
                            ),
                          ),
                          const Icon(
                            Icons.star_half, // Bintang setengah untuk rating
                            color: Colors.amber, // Warna bintang kuning
                            size: 28, // Ukuran bintang
                          ),
                          const SizedBox(
                            width: 8,
                          ), // Spasi horizontal antar elemen
                          const Text(
                            '4.5/5', // Rating hasil testimoni
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Menebalkan font
                              fontSize: 18, // Ukuran font rating
                              color: Colors.green, // Warna teks hijau
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18), // Spasi vertikal
                      const Text(
                        'Selama mengikuti perkuliahan Mobile Application Development di semester 6, saya mendapatkan banyak ilmu dan materi baru. Terimakasih banyak Pak Bagus atas bimbingannya dan tugasnya.',
                        style: TextStyle(
                          fontSize: 16, // Ukuran font untuk testimoni
                          color: Colors.black87, // Warna teks hitam gelap
                          height: 1.5, // Jarak antar baris teks
                        ),
                        textAlign:
                            TextAlign.justify, // Rata kiri-kanan pada teks
                      ),
                      const SizedBox(height: 18), // Spasi vertikal
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end, // Menyusun elemen ke kanan
                        children: const [
                          // Menampilkan gambar avatar dengan radius melingkar
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(
                              'assets/images/profile.jpg', // Gambar profil
                            ),
                          ),
                          SizedBox(width: 10), // Spasi horizontal antar elemen
                          Text(
                            '123220085', // NIM
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Menebalkan font
                              color: Colors.green, // Warna teks hijau
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30), // Spasi vertikal
            ],
          ),
        ),
      ),
    );
  }
}
