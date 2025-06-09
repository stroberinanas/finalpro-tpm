import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  late Stream<Color> _colorStream;
  bool _isFlashing = false;
  bool stillFlashing = false;

  @override
  void initState() {
    super.initState();
    stillFlashing = true;
    _startFlashlight();
    _colorStream = const Stream.empty(); // Initial empty stream
  }

  @override
  void dispose() {
    print("abc");
    stillFlashing = false;
    _stopFlashlight();
    super.dispose();
  }

  // Flashlight control
  Future<void> _startFlashlight() async {
    try {
      if (!stillFlashing) return;
      await TorchLight.enableTorch();

      await Future.delayed(Durations.medium1);

      await TorchLight.disableTorch();

      await Future.delayed(Durations.medium1);

      _startFlashlight();
    } catch (e) {
      print("Error enabling flashlight: $e");
    }
  }

  Future<void> _stopFlashlight() async {
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print("Error disabling flashlight: $e");
    }
  }

  Stream<Color> _flashColorStream() async* {
    final maxFlash = 20;
    int count = 0;
    Color currentColor = Colors.redAccent;
    while (count < maxFlash) {
      yield currentColor;
      currentColor =
          (currentColor == Colors.redAccent) ? Colors.white : Colors.redAccent;
      await Future.delayed(const Duration(milliseconds: 200));
      count++;
    }
    yield Colors.white;
    setState(() {
      _isFlashing = false;
    });
  }

  void _startFlashing() {
    setState(() {
      _isFlashing = true;
      _colorStream = _flashColorStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: StreamBuilder<Color>(
          stream: _colorStream,
          initialData: Colors.white,
          builder: (context, snapshot) {
            final color = snapshot.data ?? Colors.white;
            final isFlashing = color == Colors.redAccent;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: color,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: isFlashing ? Colors.redAccent : Colors.red,
                        size: 120,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Emergency Signal',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isFlashing ? Colors.red : Colors.redAccent,
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
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _isFlashing ? null : _startFlashing,
                        icon: const Icon(
                          Icons.warning_amber_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isFlashing ? 'Flashing...' : 'SOS Signal',
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
