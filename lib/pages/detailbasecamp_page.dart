import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DetailBasecampPage extends StatefulWidget {
  final int basecampId;

  const DetailBasecampPage({super.key, required this.basecampId});

  @override
  State<DetailBasecampPage> createState() => _DetailBasecampPageState();
}

class _DetailBasecampPageState extends State<DetailBasecampPage> {
  Map<String, dynamic>? basecampData;
  bool isLoading = true;
  String? errorMessage;

  String selectedTimezone = 'WIB';
  final List<String> timezoneOptions = [
    'WIB',
    'WITA',
    'WIT',
    'London',
    'Seoul',
    'Sydney',
    'Kairo',
    'New York',
  ];

  String selectedCurrency = 'IDR';
  final List<String> currencyOptions = [
    'IDR',
    'MYR',
    'AUD',
    'USD',
    'KRW',
    'GBP',
    'KWD',
    'THB',
  ];

  final Map<String, double> currencyRates = {
    'IDR': 1,
    'MYR': 0.00026,
    'AUD': 0.000095,
    'USD': 0.000095,
    'KRW': 0.084,
    'GBP': 0.000045,
    'KWD': 0.000019,
    'THB': 0.0020,
  };

  String? translatedRules;

  @override
  void initState() {
    super.initState();
    fetchBasecampDetail();
  }

  Future<void> fetchBasecampDetail() async {
    final url = Uri.parse(
      'https://finalpro-api-1013759214686.us-central1.run.app/basecamp/${widget.basecampId}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          setState(() {
            basecampData = data;
            isLoading = false;
            errorMessage = null;
          });
        } else {
          setState(() {
            errorMessage = 'Data Not Found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection Error: $e';
        isLoading = false;
      });
    }
  }

  String convertOpenTime(String openTime, String targetTimezone) {
    try {
      final timeParts = openTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      final Map<String, int> timezoneOffsets = {
        'WIB': 7,
        'WITA': 8,
        'WIT': 9,
        'London': 0,
        'Seoul': 9,
        'Sydney': 10,
        'Kairo': 2,
        'New York': -5,
      };

      int offsetTarget = timezoneOffsets[targetTimezone] ?? 7;
      int offsetWIB = 7;

      int convertedHour = hour + (offsetTarget - offsetWIB);
      if (convertedHour < 0) convertedHour += 24;
      if (convertedHour >= 24) convertedHour -= 24;

      final hh = convertedHour.toString().padLeft(2, '0');
      final mm = minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (_) {
      return openTime;
    }
  }

  String convertCurrency(dynamic price, String currency) {
    if (price == null) return '-';
    double priceDouble;
    try {
      priceDouble =
          price is int ? price.toDouble() : double.parse(price.toString());
    } catch (_) {
      return '-';
    }

    final rate = currencyRates[currency] ?? 1;
    final converted = priceDouble * rate;

    if (currency == 'IDR') {
      return 'IDR ${converted.toStringAsFixed(0)}';
    } else {
      return '$currency ${converted.toStringAsFixed(2)}';
    }
  }

  Future<void> translateRules() async {
    if (basecampData == null) return;
    final text = basecampData!['rules'] ?? '';
    if (text.isEmpty) return;

    setState(() {
      translatedRules = 'Translating...';
    });

    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=id|en',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText =
            json['responseData']?['translatedText'] ?? 'Translation failed';
        setState(() {
          translatedRules = translatedText;
        });
      } else {
        setState(() {
          translatedRules = 'Translation Failed';
        });
      }
    } catch (e) {
      setState(() {
        translatedRules = 'Translation Error: $e';
      });
    }
  }

  void _launchMapsUrl(String urlMaps) async {
    final Uri uri = Uri.parse(urlMaps);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot Open Maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detail Basecamp',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Basecamp'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: Center(child: Text(errorMessage!)),
      );
    }

    final hikingTimeRaw = basecampData?['hiking_time'] ?? 0;
    final elevationStr =
        basecampData?['elevation']?.toString() ??
        '-'; // convert to string safely

    final phone = basecampData?['phone'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          basecampData?['name'] ?? 'Detail Basecamp',
          style: const TextStyle(color: Colors.white), // judul warna putih
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),

      body: Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar utama dengan shadow, rounded, dan overlay judul
              if (basecampData?['photo'] != null &&
                  (basecampData!['photo'] as String).isNotEmpty)
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          basecampData!['photo'],
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          basecampData?['name'] ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 18),

              // Card info utama
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        basecampData?['description'] ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Phone number display
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Tombol buka maps
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              basecampData?['url_maps'] != null &&
                                      basecampData!['url_maps'].isNotEmpty
                                  ? () =>
                                      _launchMapsUrl(basecampData!['url_maps'])
                                  : null,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Go to Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Info hiking time & elevation dalam chip badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _infoChip(
                            icon: Icons.height,
                            label: '$elevationStr m',
                            color: Colors.orange.shade100,
                            iconColor: Colors.deepOrangeAccent,
                          ),
                          const SizedBox(width: 16),
                          _infoChip(
                            icon: Icons.access_time,
                            label: '$hikingTimeRaw hours',
                            color: Colors.blue.shade100,
                            iconColor: Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Row waktu buka (Start to Hiking) dengan dropdown timezone
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Start to Hiking : ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            convertOpenTime(
                              basecampData?['open_time'] ?? '00:00',
                              selectedTimezone,
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 15),
                          DropdownButton<String>(
                            value: selectedTimezone,
                            items:
                                timezoneOptions
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedTimezone = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Simaksi Fee : ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            convertCurrency(
                              basecampData?['price'],
                              selectedCurrency,
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 15),
                          DropdownButton<String>(
                            value: selectedCurrency,
                            items:
                                currencyOptions
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedCurrency = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Section Rules dalam card khusus
              Card(
                color: Colors.green.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.rule, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Rules',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Spacer(),
                          ElevatedButton.icon(
                            onPressed: translateRules,
                            icon: const Icon(Icons.translate, size: 18),
                            label: const Text('Translate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        basecampData?['rules'] ?? '-',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (translatedRules != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            translatedRules!,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Color.fromARGB(255, 52, 90, 108),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Chip info hiking time/elevation
  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
