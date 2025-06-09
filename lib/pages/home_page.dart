import 'package:finalpro/pages/aboutlawu_page.dart';
import 'package:finalpro/pages/basecamp_page.dart';
import 'package:finalpro/pages/compass_page.dart';
import 'package:finalpro/pages/dodonts_page.dart';
import 'package:finalpro/pages/help_page.dart';
import 'package:finalpro/pages/location_page.dart';
import 'package:finalpro/pages/necessary_page.dart';
import 'package:finalpro/pages/profile_page.dart';
import 'package:finalpro/pages/sos_page.dart';
import 'package:finalpro/pages/testimonial_page.dart';
import 'package:finalpro/pages/weather_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;

class HomePage extends StatefulWidget {
  final String name;
  final String email;

  const HomePage({super.key, required this.name, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  late final List<Widget> _pages;

  @override
  @override
  void initState() {
    super.initState();
    _pages = [
      Container(), // kosong untuk home, konten di-handle oleh content()
      LocationPage(), // halaman lokasi dengan peta
      ProfilePage(name: widget.name, email: widget.email), // halaman profil
    ];
  }

  // Ambil AppBar hanya jika sedang di halaman Home (index 0)
  PreferredSizeWidget? getAppBar() {
    if (_currentNavIndex != 0)
      return null; // sembunyikan AppBar di halaman lain
    return AppBar(
      automaticallyImplyLeading: false, // hilangkan tombol back default
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Center(
        child: Text(
          'Hi, Explorers!',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body:
          _currentNavIndex == 0
              ? content()
              : _pages[_currentNavIndex], // tampilkan halaman sesuai index menu
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_sharp),
            label: 'Pos Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_contact_calendar_sharp),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Konten halaman HomePage
  Widget content() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.green.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  'Welcome,',
                  style: TextStyle(fontSize: 16, color: Colors.green.shade900),
                ),
                subtitle: Text(
                  widget.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Carousel gambar basecamp dengan shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: carousel.CarouselSlider(
                  items:
                      [
                        'assets/images/lawu1.jpg',
                        'assets/images/lawu2.jpg',
                        'assets/images/lawu3.jpeg',
                        'assets/images/lawu4.jpg',
                      ].map((imagePath) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                  options: carousel.CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Grid dengan ikon menu
            Center(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    alignment: WrapAlignment.center,
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
    ];
    final int idx = label.hashCode % gradients.length;
    final List<Color> gradientColors = gradients[idx];

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
