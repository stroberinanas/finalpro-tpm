import 'package:flutter/material.dart';

class DoDontsPage extends StatelessWidget {
  const DoDontsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Do\'s and Don\'ts for Hiking',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                        Icons.terrain,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hiking Do\'s & Don\'ts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Card Do's
              Text(
                'Do\'s',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 10),
              ..._buildListCards(
                [
                  ['Do exercise before the hike', '🏃‍♂️'],
                  ['Do drink enough water during the hike', '💧'],
                  ['Do wear appropriate clothing and sunscreen', '☀️'],
                  ['Do take breaks and enjoy the view', '⛰️'],
                  ['Do wear comfortable footwear', '👟'],
                ],
                Colors.green.shade100,
                Colors.green,
              ),
              const SizedBox(height: 28),
              // Card Don'ts
              Text(
                'Don\'ts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 10),
              ..._buildListCards(
                [
                  ['Don\'t litter', '❌'],
                  ['Don\'t cut the hiking trail', '🚫'],
                  ['Don\'t ignore safety', '⚠️'],
                  ['Don\'t hike without proper physical preparation', '💪'],
                  ['Don\'t bring excessive items', '🎒'],
                ],
                Colors.red.shade100,
                Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build beautiful list cards for Do's and Don'ts
  List<Widget> _buildListCards(
    List<List<String>> data,
    Color cardColor,
    Color iconColor,
  ) {
    return data.map((row) {
      return Card(
        color: cardColor,
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Text(row[1], style: TextStyle(fontSize: 28, color: iconColor)),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  row[0],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
