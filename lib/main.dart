import 'package:finalpro/pages/home_page.dart';
import 'package:finalpro/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _email;
  String? _name;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final name = prefs.getString('name');

    setState(() {
      _email = email;
      _name = name;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      home:
          (_email != null && _name != null)
              ? HomePage(name: _name!, email: _email!)
              : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
