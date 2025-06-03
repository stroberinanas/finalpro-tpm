import 'dart:async';
import 'package:flutter/material.dart';

class SOSPage extends StatelessWidget {
  SOSPage({super.key});

  // Stream warna kedip: merah - putih berulang tiap 200 ms, total 20 kali
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
    yield Colors.white; // reset warna akhir
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
      body: Center(
        child: StreamBuilder<Color>(
          stream: _flashColorStream(),
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
                        onPressed:
                            snapshot.connectionState == ConnectionState.active
                                ? null
                                : () {
                                  // Trigger rebuild with a new stream by using setState in parent widget
                                  // Or use a StatefulWidget wrapping this StatelessWidget to restart stream
                                },
                        icon: const Icon(
                          Icons.warning_amber_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(
                          snapshot.connectionState == ConnectionState.active
                              ? 'Flashing...'
                              : 'SOS Signal',
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
