import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('About Lawu', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Gunung Lawu dengan shadow dan gradient overlay
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.18),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        'https://shelterjelajah.com/wp-content/uploads/2023/03/Jalur-Pendakian-Gunung-Lawu.jpg',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      'Gunung Lawu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Deskripsi singkat
            Card(
              color: Colors.green.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  'Gunung Lawu adalah gunung berapi yang terletak di perbatasan Jawa Tengah dan Jawa Timur. Dikenal dengan keindahan alam, jalur pendakian yang menantang, serta nilai sejarah dan spiritual yang tinggi.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green.shade900,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Info baris
            _buildInfoRow(
              Icons.height,
              'Elevation: 3,265 m (10,712 ft)',
              Colors.green.shade700,
              iconSize: 28,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.arrow_upward,
              'Prominence: 3,118 m',
              Colors.blue.shade700,
              iconSize: 28,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.category,
              'Category: Difficult',
              Colors.orange.shade700,
              iconSize: 28,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.location_on,
              'Province: East Java & Central Java',
              Colors.purple.shade700,
              iconSize: 28,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.warning_amber_rounded,
              'Eruptions: 1885',
              Colors.red.shade700,
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create icon-text rows with custom icon color and size
  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color iconColor, {
    double iconSize = 20,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
