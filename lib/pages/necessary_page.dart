import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NecessaryPage extends StatefulWidget {
  const NecessaryPage({super.key});

  @override
  _NecessaryPageState createState() => _NecessaryPageState();
}

class _NecessaryPageState extends State<NecessaryPage> {
  // Daftar item perlengkapan dan status checked
  // Daftar item perlengkapan dan status checked
  Map<String, bool> items = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Muat status checkbox dari SharedPreferences
  }

  // Muat status centang dari SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Menyusun daftar item dari SharedPreferences
      items = {
        'Carrier': prefs.getBool('Carrier') ?? false,
        'Trekking Shoes and Hiking Sandals':
            prefs.getBool('Trekking Shoes and Hiking Sandals') ?? false,
        'Socks': prefs.getBool('Socks') ?? false,
        'Pants and Appropriate Clothing':
            prefs.getBool('Pants and Appropriate Clothing') ?? false,
        'Duck Down/Waterproof Jacket':
            prefs.getBool('Duck Down/Waterproof Jacket') ?? false,
        'Hat and Gloves': prefs.getBool('Hat and Gloves') ?? false,
        'Headlamp/Flashlight': prefs.getBool('Headlamp/Flashlight') ?? false,
        'Sleeping Bag': prefs.getBool('Sleeping Bag') ?? false,
        'TNI/Aluminum Foil Mat':
            prefs.getBool('TNI/Aluminum Foil Mat') ?? false,
        'Personal Medications': prefs.getBool('Personal Medications') ?? false,
        'Shower and Prayer Equipment':
            prefs.getBool('Shower and Prayer Equipment') ?? false,
        'Gaiters': prefs.getBool('Gaiters') ?? false,
        'Raincoat/Rain Jacket': prefs.getBool('Raincoat/Rain Jacket') ?? false,
        'Tissues': prefs.getBool('Tissues') ?? false,
        'Spare Batteries': prefs.getBool('Spare Batteries') ?? false,
        'Trashbag': prefs.getBool('Trashbag') ?? false,
        'Trekking Poles': prefs.getBool('Trekking Poles') ?? false,
        'Snacks and Water': prefs.getBool('Snacks and Water') ?? false,
        'Mask/Face Buff': prefs.getBool('Mask/Face Buff') ?? false,
        'ID Card Copy': prefs.getBool('ID Card Copy') ?? false,
        'Health Certificate': prefs.getBool('Health Certificate') ?? false,
        'Tent': prefs.getBool('Tent') ?? false,
        'Cooking Equipment': prefs.getBool('Cooking Equipment') ?? false,
      };
    });
  }

  // Simpan status centang ke SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (String key in items.keys) {
      await prefs.setBool(key, items[key]!);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Green background for AppBar
        title: const Text(
          'Necessary Gear Checklist',
          style: TextStyle(color: Colors.white), // White text for title
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back button
          onPressed: () {
            _savePreferences(); // Simpan status sebelum kembali
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Container(
        color: Colors.white, // White background for the body
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
                      final checked = items[key] ?? false;
                      return Card(
                        elevation: checked ? 5 : 2,
                        color:
                            checked
                                ? Colors.green.shade100
                                : Colors.green.shade50,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ),
                          leading: Checkbox(
                            value: checked,
                            onChanged: (bool? value) {
                              setState(() {
                                items[key] = value!;
                              });
                              _savePreferences();
                            },
                            activeColor:
                                Colors.green, // Green color for checked box
                          ),
                          title: Row(
                            children: [
                              Icon(
                                checked
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: checked ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  key,
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
                                            : null,
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
                onPressed: () {
                  setState(() {
                    items.updateAll((key, value) => false);
                  });
                  _savePreferences();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Checklist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
