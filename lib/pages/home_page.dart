import 'package:finalpro/pages/aboutlawu_page.dart'; // Mengimpor halaman AboutLawu
import 'package:finalpro/pages/basecamp_page.dart'; // Mengimpor halaman Basecamp
import 'package:finalpro/pages/compass_page.dart'; // Mengimpor halaman Compass
import 'package:finalpro/pages/dodonts_page.dart'; // Mengimpor halaman DoDonts
import 'package:finalpro/pages/help_page.dart'; // Mengimpor halaman Help
import 'package:finalpro/pages/location_page.dart'; // Mengimpor halaman Location
import 'package:finalpro/pages/necessary_page.dart'; // Mengimpor halaman Necessary
import 'package:finalpro/pages/profile_page.dart'; // Mengimpor halaman Profile
import 'package:finalpro/pages/sos_page.dart'; // Mengimpor halaman SOS
import 'package:finalpro/pages/testimonial_page.dart'; // Mengimpor halaman Testimonial
import 'package:finalpro/pages/weather_page.dart'; // Mengimpor halaman Weather
import 'package:flutter/material.dart'; // Mengimpor pustaka Material Design
import 'package:carousel_slider/carousel_slider.dart'
    as carousel; // Mengimpor pustaka untuk carousel slider

// HomePage widget untuk tampilan utama aplikasi
class HomePage extends StatefulWidget {
  final String name; // Menyimpan nama pengguna yang diteruskan dari login
  final String email; // Menyimpan email pengguna yang diteruskan dari login

  const HomePage({
    super.key,
    required this.name,
    required this.email,
  }); // Konstruktor untuk menerima parameter name dan email

  @override
  State<HomePage> createState() => _HomePageState(); // Membuat state untuk widget HomePage
}

// State untuk widget HomePage
class _HomePageState extends State<HomePage> {
  int _currentNavIndex =
      0; // Indeks untuk halaman yang sedang aktif di bottom navigation
  late final List<Widget>
  _pages; // Daftar halaman yang akan ditampilkan berdasarkan indeks

  @override
  void initState() {
    super.initState();
    _pages = [
      Container(), // Halaman kosong untuk home
      LocationPage(), // Halaman lokasi dengan peta
      ProfilePage(
        name: widget.name,
        email: widget.email,
      ), // Halaman profil pengguna
    ];
  }

  // Fungsi untuk mendapatkan AppBar hanya jika sedang di halaman Home (index 0)
  PreferredSizeWidget? getAppBar() {
    if (_currentNavIndex != 0)
      return null; // Jika halaman bukan Home, sembunyikan AppBar
    return AppBar(
      automaticallyImplyLeading:
          false, // Menghilangkan tombol back default di AppBar
      backgroundColor:
          Colors.white, // Mengatur warna latar belakang AppBar menjadi putih
      elevation: 0, // Mengatur elevasi AppBar menjadi 0 (tanpa bayangan)
      title: const Center(
        child: Text(
          'Hi, Explorers!', // Teks judul AppBar
          style: TextStyle(
            fontStyle: FontStyle.italic, // Gaya font italic
            fontWeight: FontWeight.bold, // Gaya font bold
            color: Colors.green, // Warna teks hijau
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Mengatur warna latar belakang halaman utama
      appBar: getAppBar(), // Menampilkan AppBar jika sedang di halaman Home
      body:
          _currentNavIndex == 0
              ? content()
              : _pages[_currentNavIndex], // Menampilkan halaman sesuai dengan indeks
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex, // Menyimpan posisi halaman aktif
        selectedItemColor: Colors.green, // Warna item yang dipilih
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        onTap: (index) {
          setState(() {
            _currentNavIndex =
                index; // Mengubah halaman yang ditampilkan sesuai dengan tab yang dipilih
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ), // Tab Home
          BottomNavigationBarItem(
            icon: Icon(Icons.map_sharp),
            label: 'Pos Location', // Tab Lokasi
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_contact_calendar_sharp),
            label: 'Profile', // Tab Profil
          ),
        ],
      ),
    );
  }

  // Konten halaman HomePage
  Widget content() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10), // Padding di seluruh konten
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Mengatur alignment kolom ke kiri
          children: [
            // Greeting Card untuk menyapa pengguna
            Card(
              elevation: 4, // Menambahkan efek bayangan pada card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  16,
                ), // Sudut melengkung pada card
              ),
              color: Colors.green.shade50, // Mengatur warna latar belakang card
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green, // Warna latar belakang ikon
                  child: Icon(Icons.person, color: Colors.white), // Ikon avatar
                ),
                title: Text(
                  'Welcome,', // Teks yang muncul di bagian judul
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade900,
                  ), // Gaya teks judul
                ),
                subtitle: Text(
                  widget.name, // Nama pengguna ditampilkan di bagian subtitle
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Gaya font bold
                    fontSize: 18, // Ukuran font
                    color: Colors.green.shade800, // Warna teks hijau gelap
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ), // Jarak antara greeting card dan carousel
            // Carousel gambar basecamp dengan shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  16,
                ), // Menambahkan sudut melengkung pada gambar
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  16,
                ), // Menambahkan sudut melengkung pada gambar
                child: carousel.CarouselSlider(
                  items:
                      [
                        'assets/images/lawu1.jpg',
                        'assets/images/lawu2.jpg',
                        'assets/images/lawu3.jpeg',
                        'assets/images/lawu4.jpg',
                      ].map((imagePath) {
                        return Container(
                          width:
                              MediaQuery.of(context)
                                  .size
                                  .width, // Mengatur lebar gambar sesuai lebar layar
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                imagePath,
                              ), // Menampilkan gambar dari path
                              fit:
                                  BoxFit
                                      .cover, // Menyesuaikan gambar agar memenuhi area
                            ),
                          ),
                        );
                      }).toList(),
                  options: carousel.CarouselOptions(
                    height: 180, // Tinggi carousel
                    autoPlay: true, // Menyalakan autoplay untuk carousel
                    enlargeCenterPage:
                        true, // Membuat gambar tengah lebih besar
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18), // Jarak setelah carousel
            // Grid dengan ikon menu
            Center(
              child: Card(
                elevation: 2, // Efek bayangan pada card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Sudut melengkung pada card
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12), // Padding di dalam card
                  child: Wrap(
                    spacing: 18, // Jarak horizontal antar ikon menu
                    runSpacing: 18, // Jarak vertikal antar ikon menu
                    alignment:
                        WrapAlignment.center, // Menyusun ikon secara terpusat
                    children: [
                      _menuIcon(Icons.view_carousel_outlined, 'About', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutPage()),
                        );
                      }),
                      _menuIcon(Icons.account_balance_outlined, 'Basecamp', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BasecampPage(),
                          ),
                        );
                      }),
                      _menuIcon(Icons.list_alt_rounded, 'Necessary', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NecessaryPage(),
                          ),
                        );
                      }),
                      _menuIcon(Icons.cloud, 'Weather', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeatherPage(),
                          ),
                        );
                      }),
                      _menuIcon(Icons.library_add_check_outlined, 'Rules', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoDontsPage(),
                          ),
                        );
                      }),
                      _menuIcon(
                        Icons.compass_calibration_rounded,
                        'Compass',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompassPage(),
                            ),
                          );
                        },
                      ),
                      _menuIcon(Icons.sos_sharp, 'SOS', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SOSPage()),
                        );
                      }),
                      _menuIcon(Icons.help, 'Help', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HelpPage()),
                        );
                      }),
                      _menuIcon(Icons.feedback, 'Testimonial', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestimonialPage(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk ikon menu dengan gradient dan shadow
  Widget _menuIcon(IconData icon, String label, Function() onTap) {
    // Gradient warna acak
    final List<List<Color>> gradients = [
      [Colors.green, Colors.lightGreen],
      [Colors.blue, Colors.lightBlueAccent],
      [Colors.orange, Colors.deepOrangeAccent],
      [Colors.purple, Colors.purpleAccent],
      [Colors.teal, Colors.tealAccent],
      [Colors.red, Colors.redAccent],
      [Colors.indigo, Colors.indigoAccent],
      [Colors.pink, Colors.pinkAccent],
      [Colors.yellow, Colors.amber],
    ];
    final int idx =
        label.hashCode %
        gradients.length; // Memilih gradient acak berdasarkan hash label
    final List<Color> gradientColors = gradients[idx];

    return GestureDetector(
      onTap: onTap, // Fungsi yang akan dijalankan saat menu di-tap
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Menyusun widget ke tengah
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Padding di dalam lingkaran
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Bentuk lingkaran
              gradient: LinearGradient(
                colors: gradientColors, // Gradient warna acak
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ), // Ikon menu dengan warna putih
          ),
          const SizedBox(height: 6), // Jarak antara ikon dan label
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87, // Warna teks label
              fontWeight: FontWeight.w600, // Gaya font label
              fontSize: 14, // Ukuran font label
              letterSpacing: 0.2, // Spasi antar huruf
            ),
            textAlign: TextAlign.center, // Menyusun teks agar rata tengah
          ),
        ],
      ),
    );
  }
}

/*
1. gradients List
Tipe data: List<List<Color>> artinya ini adalah sebuah daftar (list) yang berisi sub-daftar (list) dengan tipe data Color. Setiap sub-daftar berisi dua elemen warna (Color).

Fungsi: Daftar ini mendefinisikan pasangan warna (gradient) yang digunakan untuk memberikan efek gradien pada widget di UI aplikasi. Gradien terdiri dari dua warna yang saling berpadu, dimulai dari warna pertama ke warna kedua. Contoh:

[Colors.green, Colors.lightGreen]: Gradien dari hijau tua ke hijau muda.

[Colors.blue, Colors.lightBlueAccent]: Gradien dari biru ke biru terang.

Gradien ini akan digunakan secara acak berdasarkan label yang diberikan pada ikon menu.

2. label.hashCode:

Fungsi hashCode menghasilkan nilai numerik (integer) berdasarkan objek yang diberikan, dalam hal ini adalah string label. hashCode adalah nilai unik yang dihasilkan dari string tersebut.

Misalnya, jika label adalah "Home", maka hashCode akan menghasilkan angka tertentu yang dapat diakses melalui objek string tersebut.

gradients.length:

gradients.length mengembalikan panjang daftar gradients, yaitu berapa banyak pasangan warna gradien yang ada. Dalam hal ini, ada 8 pasangan warna (gradien), jadi gradients.length akan menghasilkan nilai 8.

label.hashCode % gradients.length:

Operator % adalah operator modulus yang menghasilkan sisa pembagian. Artinya, label.hashCode dibagi dengan panjang daftar gradients (8), dan hasilnya adalah sisa dari pembagian tersebut, yang pasti berada di antara 0 hingga 7. Ini digunakan untuk menghasilkan indeks yang sesuai dengan panjang daftar gradients.

Dengan cara ini, hashCode dari setiap label menghasilkan indeks yang berbeda pada daftar gradients, yang memastikan bahwa setiap label mendapatkan warna gradien yang berbeda.

3. Setelah menghitung indeks (idx) berdasarkan label, kode ini memilih pasangan warna (gradien) yang sesuai dari daftar gradients menggunakan indeks yang dihitung sebelumnya.

Contoh: Jika idx adalah 3, maka gradientColors akan berisi pasangan warna [Colors.purple, Colors.purpleAccent].
*/
