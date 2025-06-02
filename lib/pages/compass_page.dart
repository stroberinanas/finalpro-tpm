import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
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
            ? "${_elevation!.toStringAsFixed(0)} m"
            : "Elevation not available";
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          'Compass',
          style: TextStyle(color: Colors.white, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: const Size(300, 300),
                painter: _ModernCompassPainter(heading),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      directionLabel,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _buildInfoRow("LATITUDE", latitudeStr),
                    const SizedBox(height: 8),
                    _buildInfoRow("LONGITUDE", longitudeStr),
                    const SizedBox(height: 8),
                    _buildInfoRow("ELEVATION", elevationStr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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

    // Outer glow effect
    final glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.blue.withOpacity(0.2), Colors.transparent],
            stops: [0.7, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, glowPaint);

    // Main compass circle
    final circlePaint =
        Paint()
          ..color = Colors.grey[850]!
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 10, circlePaint);

    // Inner gradient circle
    final innerGradient = RadialGradient(
      colors: [Colors.grey[900]!, Colors.grey[800]!],
    );
    final innerPaint =
        Paint()
          ..shader = innerGradient.createShader(
            Rect.fromCircle(center: center, radius: radius - 30),
          )
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 30, innerPaint);

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
          ..strokeWidth = 3;

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
      fontSize: 24,
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

    // Center circle
    final centerCirclePaint =
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.green, Colors.blue[900]!],
          ).createShader(Rect.fromCircle(center: center, radius: 12));
    canvas.drawCircle(center, 12, centerCirclePaint);

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ModernCompassPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}
