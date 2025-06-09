import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'Browse Basecamps',
        'desc': 'Search for different basecamps to plan your next hike.',
        'icon': Icons.map,
      },
      {
        'title': 'Check Your Gear',
        'desc': 'View a checklist of necessary gear for your hiking trip.',
        'icon': Icons.checklist_rtl,
      },
      {
        'title': 'Know the Rules',
        'desc': 'Learn the dos and don’ts for a safe hike.',
        'icon': Icons.rule,
      },
      {
        'title': 'View Location',
        'desc': 'Use the compass to find your way to the basecamp.',
        'icon': Icons.explore,
      },
      {
        'title': 'SOS Alert',
        'desc': 'In case of an emergency, use the SOS feature for help.',
        'icon': Icons.sos,
      },
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Help & Tutorial',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        Icons.help_outline,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'How to Use This App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Deskripsi aplikasi dalam card
              Card(
                color: Colors.green.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    "This app helps you navigate hiking trails, find basecamps, and more. "
                    "Follow the tutorial below to get started with our features.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tutorial Steps dalam card
              ...steps
                  .map(
                    (step) => _buildStepCard(
                      step['title'],
                      step['desc'],
                      step['icon'],
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(String title, String description, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
