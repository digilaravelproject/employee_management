import 'package:geolocator/geolocator.dart';
import '../../utils/logger.dart';

class LocationService {
  /// Fetches the user's current GPS position (latitude and longitude).
  /// Handles permission checks, location service status, and fallbacks.
  static Future<Position?> getCurrentLocation({
    Function(String error)? onError,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final msg = 'Location services (GPS) are disabled. Please turn on GPS.';
        Logger.w('LocationService => $msg');
        onError?.call(msg);
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final msg = 'Location permission was denied. Please allow location access.';
          Logger.w('LocationService => $msg');
          onError?.call(msg);
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final msg = 'Location permission is permanently denied. Please allow it from app settings.';
        Logger.w('LocationService => $msg');
        onError?.call(msg);
        return null;
      }

      // Fetch high accuracy position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      Logger.d('LocationService => Position retrieved: lat=${position.latitude}, long=${position.longitude}');
      return position;
    } catch (e) {
      Logger.e('LocationService => Error getting current position: $e');
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          Logger.d('LocationService => Using last known position: lat=${lastKnown.latitude}, long=${lastKnown.longitude}');
          return lastKnown;
        }
      } catch (_) {}

      final msg = 'Unable to get current location. Please check your GPS and try again.';
      onError?.call(msg);
      return null;
    }
  }
}
