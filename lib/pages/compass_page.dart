import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double? _heading;
  StreamSubscription? _compassSubscription;

  final Location _location = Location();

  double? _latitude;
  double? _longitude;
  double? _elevation;

  @override
  void initState() {
    super.initState();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading;
      });
    });
    _requestLocationPermissionAndListen();
  }

  void _requestLocationPermissionAndListen() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _latitude = currentLocation.latitude;
        _longitude = currentLocation.longitude;
        _elevation = currentLocation.altitude;
      });
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  String _directionLabel(double direction) {
    if (direction >= 337.5 || direction < 22.5) return "NORTH";
    if (direction >= 22.5 && direction < 67.5) return "NORTHEAST";
    if (direction >= 67.5 && direction < 112.5) return "EAST";
    if (direction >= 112.5 && direction < 157.5) return "SOUTHEAST";
    if (direction >= 157.5 && direction < 202.5) return "SOUTH";
    if (direction >= 202.5 && direction < 247.5) return "SOUTHWEST";
    if (direction >= 247.5 && direction < 292.5) return "WEST";
    if (direction >= 292.5 && direction < 337.5) return "NORTHWEST";
    return "";
  }

  String _formatCoordinate(double? coord, bool isLatitude) {
    if (coord == null) return "...";
    final degrees = coord.abs().floor();
    final minutes = ((coord.abs() - degrees) * 60).floor();
    final seconds = (((coord.abs() - degrees) * 60 - minutes) * 60).floor();
    final direction =
        isLatitude ? (coord >= 0 ? "N" : "S") : (coord >= 0 ? "E" : "W");
    return "$degrees°$minutes'${seconds}\" $direction";
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading ?? 0;
    final directionLabel = _directionLabel(heading);

    final latitudeStr = _formatCoordinate(_latitude, true);
    final longitudeStr = _formatCoordinate(_longitude, false);
    final elevationStr =
        _elevation != null
            ? "${_elevation!.toStringAsFixed(0)} M"
            : "Elevation Not Available";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,

        elevation: 0,
        title: const Text(
          'Compass Page',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header ilustrasi kompas
                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 10),
                  child: Column(children: [const SizedBox(height: 8)]),
                ),
                // Kompas dengan shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(180),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.13),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: _ModernCompassPainter(heading),
                  ),
                ),
                const SizedBox(height: 36),
                // Arah dan derajat
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        directionLabel,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${heading.toStringAsFixed(1)}°",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Info koordinat dan elevasi dalam card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
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
                        children: [
                          _buildInfoRowWithIcon(
                            Icons.my_location,
                            "LATITUDE",
                            latitudeStr,
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRowWithIcon(
                            Icons.explore,
                            "LONGITUDE",
                            longitudeStr,
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRowWithIcon(
                            Icons.terrain,
                            "ELEVATION",
                            elevationStr,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ModernCompassPainter extends CustomPainter {
  final double heading;

  _ModernCompassPainter(this.heading);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    // Main compass circle
    final circlePaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 10, circlePaint);

    // Ticks
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);

    final tickPaintSmall =
        Paint()
          ..color = Colors.grey[600]!
          ..strokeWidth = 1.5;
    final tickPaintMain =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 6) {
      final isMainTick = (i % 30 == 0);
      final tickLength = isMainTick ? 20.0 : 10.0;
      final paint = isMainTick ? tickPaintMain : tickPaintSmall;

      final angle = (i - 90) * math.pi / 180;
      final start = Offset(
        (radius - tickLength - 20) * math.cos(angle),
        (radius - tickLength - 20) * math.sin(angle),
      );
      final end = Offset(
        (radius - 20) * math.cos(angle),
        (radius - 20) * math.sin(angle),
      );

      canvas.drawLine(start, end, paint);

      // Add degree numbers for main ticks
      if (isMainTick) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final textOffset = Offset(
          (radius - 45) * math.cos(angle) - textPainter.width / 2,
          (radius - 45) * math.sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // Direction letters
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];
    final directionTextStyle = TextStyle(
      color: Colors.green,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < directions.length; i++) {
      final angle = (angles[i] - 90) * math.pi / 180;
      final textPainter = TextPainter(
        text: TextSpan(text: directions[i], style: directionTextStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final pos = Offset(
        (radius - 70) * math.cos(angle) - textPainter.width / 2,
        (radius - 70) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, pos);
    }

    canvas.restore();

    // Needle
    final needleLength = radius * 0.6;
    final needlePaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.red, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromPoints(
              Offset(center.dx - 8, center.dy - needleLength),
              Offset(center.dx + 8, center.dy + needleLength),
            ),
          )
          ..style = PaintingStyle.fill;

    Path needlePath = Path();
    needlePath.moveTo(center.dx, center.dy - needleLength);
    needlePath.lineTo(center.dx - 8, center.dy);
    needlePath.lineTo(center.dx, center.dy + needleLength * 0.3);
    needlePath.lineTo(center.dx + 8, center.dy);
    needlePath.close();
    canvas.drawPath(needlePath, needlePaint);
  }

  @override
  bool shouldRepaint(covariant _ModernCompassPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}
