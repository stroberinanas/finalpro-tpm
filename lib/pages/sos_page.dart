import 'dart:async';
import 'package:flutter/material.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  bool _isFlashing = false;
  Color _flashColor = Colors.white;
  Timer? _flashTimer;
  int _flashCount = 0;
  final int _maxFlash = 20; // Banyak kedipan

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSOS() async {
    if (_isFlashing) return;

    setState(() {
      _isFlashing = true;
      _flashColor = Colors.redAccent;
      _flashCount = 0;
    });

    _flashTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _flashColor =
            (_flashColor == Colors.redAccent) ? Colors.white : Colors.redAccent;
      });
      _flashCount++;

      if (_flashCount >= _maxFlash) {
        timer.cancel();
        setState(() {
          _isFlashing = false;
          _flashColor = Colors.white;
        });
        // Tidak ada call/launch lagi di sini
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _flashColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _isFlashing ? Colors.redAccent : Colors.red,
                  size: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  'Emergency Signal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _isFlashing ? Colors.red : Colors.redAccent,
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
                  onPressed: _isFlashing ? null : _startSOS,
                  icon: const Icon(
                    Icons.warning_amber_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isFlashing ? 'Flashing...' : 'SOS Signal',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
