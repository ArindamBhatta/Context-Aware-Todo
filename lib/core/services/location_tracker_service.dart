import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/features/add_todo/data/cache/todo_database.dart';

class LocationTrackerService {
  // Distance in meters to consider "at" the location
  static const double _thresholdDistance = 200.0;

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return null;
      }

      Position? position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      ).catchError((_) async {
        return await Geolocator.getLastKnownPosition() ??
            Position(
              longitude: 0,
              latitude: 0,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
      });

      return position;
    } catch (e) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  Future<void> setHomeLocation(double lat, double lng) async {
    final db = await TodoDatabase.instance.database;
    await db.insert(
      'locations',
      {'category': 'Home', 'latitude': lat, 'longitude': lng},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setOfficeLocation(double lat, double lng) async {
    final db = await TodoDatabase.instance.database;
    await db.insert(
      'locations',
      {'category': 'Office', 'latitude': lat, 'longitude': lng},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> hasHomeLocation() async {
    final db = await TodoDatabase.instance.database;
    final res = await db.query(
      'locations',
      where: 'category = ?',
      whereArgs: ['Home'],
    );
    return res.isNotEmpty;
  }

  Future<bool> hasOfficeLocation() async {
    final db = await TodoDatabase.instance.database;
    final res = await db.query(
      'locations',
      where: 'category = ?',
      whereArgs: ['Office'],
    );
    return res.isNotEmpty;
  }

  Future<String?> getCurrentLocationCategory(Position position) async {
    final db = await TodoDatabase.instance.database;
    final rows = await db.query('locations');

    for (final row in rows) {
      final category = row['category'] as String;
      final lat = row['latitude'] as double;
      final lng = row['longitude'] as double;

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );

      if (distance <= _thresholdDistance) {
        return category;
      }
    }

    return null;
  }
}
