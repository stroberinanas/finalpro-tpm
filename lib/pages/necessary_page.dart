import 'package:flutter/material.dart'; // Mengimpor paket Flutter untuk UI
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor paket untuk menyimpan data secara lokal

// Widget utama halaman NecessaryPage
class NecessaryPage extends StatefulWidget {
  const NecessaryPage({super.key});

  @override
  _NecessaryPageState createState() => _NecessaryPageState();
}

class _NecessaryPageState extends State<NecessaryPage> {
  // Daftar item perlengkapan dan status checked
  Map<String, bool> items =
      {}; // Menyimpan item perlengkapan dengan status centang

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Muat status checkbox dari SharedPreferences
  }

  // Muat status centang dari SharedPreferences berdasarkan ID pengguna
  Future<void> _loadPreferences() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengakses SharedPreferences
    final idUser = prefs.getInt(
      'id',
    ); // Mengambil ID pengguna dari SharedPreferences

    if (idUser != null) {
      final key =
          'checklist_$idUser'; // Membuat key dinamis untuk menyimpan data berdasarkan ID pengguna

      // Daftar nama item perlengkapan
      List<String> itemNames = [
        'Carrier',
        'Trekking Shoes and Hiking Sandals',
        'Socks',
        'Pants and Appropriate Clothing',
        'Duck Down/Waterproof Jacket',
        'Hat and Gloves',
        'Headlamp/Flashlight',
        'Sleeping Bag',
        'TNI/Aluminum Foil Mat',
        'Personal Medications',
        'Shower and Prayer Equipment',
        'Gaiters',
        'Raincoat/Rain Jacket',
        'Tissues',
        'Spare Batteries',
        'Trashbag',
        'Trekking Poles',
        'Snacks and Water',
        'Mask/Face Buff',
        'ID Card Copy',
        'Health Certificate',
        'Tent',
        'Cooking Equipment',
      ];

      // Memuat status checkbox (checked/unchecked) ke dalam map
      setState(() {
        items = Map.fromIterable(
          itemNames, // Menggunakan daftar nama item
          key: (item) => item,
          value:
              (item) =>
                  prefs.getBool('$key-$item') ??
                  false, // Mengambil status centang untuk setiap item
        );
      });
    }
  }

  // Simpan status centang ke SharedPreferences
  Future<void> _savePreferences() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengakses SharedPreferences
    final idUser = prefs.getInt(
      'id',
    ); // Mengambil ID pengguna dari SharedPreferences

    if (idUser != null) {
      final key =
          'checklist_$idUser'; // Membuat key dinamis untuk menyimpan data berdasarkan ID pengguna

      // Menyimpan status centang untuk setiap item
      for (String keyItem in items.keys) {
        await prefs.setBool(
          '$key-$keyItem',
          items[keyItem]!,
        ); // Menyimpan status centang item
      }
    }
  }

  // Reset checklist untuk pengguna saat ini dengan menghapus preferensi
  Future<void> _resetPreferences() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengakses SharedPreferences
    final idUser = prefs.getInt(
      'id',
    ); // Mengambil ID pengguna dari SharedPreferences

    if (idUser != null) {
      final key =
          'checklist_$idUser'; // Membuat key dinamis untuk menyimpan data berdasarkan ID pengguna

      // Menghapus preferensi item secara individual dari SharedPreferences
      for (String keyItem in items.keys) {
        await prefs.remove(
          '$key-$keyItem',
        ); // Menghapus status centang untuk item
      }

      setState(() {
        // Reset items ke 'false' (belum dicentang) di UI
        items.updateAll(
          (key, value) => false,
        ); // Set semua item sebagai unchecked
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Latar belakang AppBar berwarna hijau
        title: const Text(
          'Necessary Gear Checklist',
          style: TextStyle(color: Colors.white), // Teks judul berwarna putih
        ),
        centerTitle: true, // Judul berada di tengah
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Tombol kembali
          onPressed: () {
            _savePreferences(); // Simpan status sebelum kembali
            Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Container(
        color: Colors.white, // Latar belakang body berwarna putih
        padding: const EdgeInsets.all(
          16.0,
        ), // Padding untuk konten di dalam body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan ilustrasi
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.backpack_rounded,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Checklist Necessary Gear',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                children:
                    items.keys.map((String key) {
                      final checked =
                          items[key] ?? false; // Status centang untuk item
                      return Card(
                        elevation:
                            checked
                                ? 5
                                : 2, // Elevasi kartu lebih tinggi jika dicentang
                        color:
                            checked
                                ? Colors.green.shade100
                                : Colors
                                    .green
                                    .shade50, // Warna kartu sesuai dengan status centang
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ), // Margin kartu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            14,
                          ), // Sudut kartu melengkung
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ),
                          leading: Checkbox(
                            value: checked, // Status checkbox
                            onChanged: (bool? value) {
                              setState(() {
                                items[key] = value!; // Update status checkbox
                              });
                              _savePreferences(); // Simpan perubahan ke SharedPreferences
                            },
                            activeColor:
                                Colors.green, // Warna checkbox saat dicentang
                          ),
                          title: Row(
                            children: [
                              Icon(
                                checked
                                    ? Icons.check_circle
                                    : Icons
                                        .circle_outlined, // Ganti ikon sesuai status
                                color: checked ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  key, // Nama item perlengkapan
                                  style: TextStyle(
                                    color:
                                        checked
                                            ? Colors.green.shade900
                                            : Colors.black,
                                    fontSize: 15,
                                    fontWeight:
                                        checked
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    decoration:
                                        checked
                                            ? TextDecoration.lineThrough
                                            : null, // Garis tengah jika dicentang
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed:
                    _resetPreferences, // Reset checklist saat tombol ditekan
                icon: const Icon(Icons.refresh), // Ikon refresh
                label: const Text('Reset Checklist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Latar belakang tombol hijau
                  foregroundColor: Colors.white, // Teks tombol putih
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18), // Sudut melengkung
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold, // Teks tebal
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
