import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter untuk UI
import 'package:torch_light/torch_light.dart'; // Mengimpor pustaka untuk mengontrol senter (torch)

class SOSPage extends StatefulWidget {
  const SOSPage({super.key}); // Konstruktor untuk widget SOSPage

  @override
  State<SOSPage> createState() => _SOSPageState(); // Membuat State untuk widget ini
}

class _SOSPageState extends State<SOSPage> {
  late Stream<Color>
  _colorStream; // Stream untuk mengontrol warna yang berkedip
  bool _isFlashing = false; // Status apakah senter sedang berkedip
  bool stillFlashing =
      false; // Variabel untuk mengontrol apakah proses berkedip masih berjalan

  @override
  void initState() {
    super.initState();
    stillFlashing = true; // Menandakan bahwa proses berkedip sedang aktif
    _startFlashlight(); // Memulai senter untuk berkedip
    _colorStream = const Stream.empty(); // Inisialisasi dengan stream kosong
  }

  @override
  void dispose() {
    print("abc"); // Mencetak "abc" saat widget dibuang
    stillFlashing = false; // Menandakan bahwa proses berkedip dihentikan
    _stopFlashlight(); // Mematikan senter saat widget dihancurkan
    super.dispose();
  }

  // Fungsi untuk mengaktifkan senter
  Future<void> _startFlashlight() async {
    try {
      if (!stillFlashing)
        return; // Jika proses berkedip sudah dihentikan, keluar
      await TorchLight.enableTorch(); // Mengaktifkan senter

      await Future.delayed(
        Durations.medium1,
      ); // Menunggu beberapa waktu (delay)

      await TorchLight.disableTorch(); // Menonaktifkan senter

      await Future.delayed(Durations.medium1); // Menunggu lagi

      _startFlashlight(); // Mengulang proses berkedip
    } catch (e) {
      print("Error enabling flashlight: $e"); // Menangani error jika ada
    }
  }

  // Fungsi untuk mematikan senter
  Future<void> _stopFlashlight() async {
    try {
      await TorchLight.disableTorch(); // Menonaktifkan senter
    } catch (e) {
      print("Error disabling flashlight: $e"); // Menangani error jika ada
    }
  }

  // Fungsi untuk menghasilkan stream warna berkedip
  Stream<Color> _flashColorStream() async* {
    final maxFlash = 20; // Jumlah maksimal kedipan
    int count = 0; // Menghitung jumlah kedipan
    Color currentColor = Colors.redAccent; // Warna awal adalah merah terang

    while (count < maxFlash) {
      yield currentColor; // Mengirimkan warna saat ini ke stream
      currentColor =
          (currentColor == Colors.redAccent)
              ? Colors.white
              : Colors.redAccent; // Ganti warna antara merah terang dan putih
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // Delay antara kedipan
      count++; // Menambah hitungan kedipan
    }
    yield Colors
        .white; // Setelah selesai, mengirim warna putih sebagai tanda berhenti berkedip
    setState(() {
      _isFlashing = false; // Menandakan bahwa proses kedipan selesai
    });
  }

  // Fungsi untuk memulai kedipan warna
  void _startFlashing() {
    setState(() {
      _isFlashing = true; // Menandakan bahwa kedipan dimulai
      _colorStream = _flashColorStream(); // Memulai stream warna berkedip
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent, // Warna latar belakang AppBar
        elevation: 0,
        title: const Text(
          'SOS', // Judul halaman
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Menyelaraskan judul di tengah
      ),
      body: Center(
        child: StreamBuilder<Color>(
          stream: _colorStream, // Mengambil stream warna yang sedang berkedip
          initialData: Colors.white, // Warna awal adalah putih
          builder: (context, snapshot) {
            final color =
                snapshot.data ??
                Colors.white; // Mendapatkan data warna dari stream
            final isFlashing =
                color ==
                Colors
                    .redAccent; // Memeriksa apakah warna merah terang (tanda kedipan)

            return AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ), // Durasi animasi perubahan warna
              color:
                  color, // Mengubah warna container sesuai dengan warna yang diterima dari stream
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(
                    32,
                  ), // Padding di sekitar konten
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded, // Ikon peringatan
                        color:
                            isFlashing
                                ? Colors.redAccent
                                : Colors
                                    .red, // Mengubah warna ikon berdasarkan kedipan
                        size: 120, // Ukuran ikon
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Emergency Signal', // Teks indikator sinyal darurat
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color:
                              isFlashing
                                  ? Colors.red
                                  : Colors
                                      .redAccent, // Mengubah warna teks berdasarkan kedipan
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Press the button below to flash the SOS emergency signal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, // Warna tombol
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              18,
                            ), // Sudut tombol melengkung
                          ),
                        ),
                        onPressed:
                            _isFlashing
                                ? null
                                : _startFlashing, // Menonaktifkan tombol saat sedang berkedip
                        icon: const Icon(
                          Icons.warning_amber_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isFlashing
                              ? 'Flashing...'
                              : 'SOS Signal', // Teks pada tombol
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
