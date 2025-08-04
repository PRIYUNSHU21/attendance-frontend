import 'dart:math';

/// Utility class for location-related calculations
class LocationUtils {
  /// Calculate distance using Haversine formula with higher precision
  /// Returns distance in meters
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) => degrees * (pi / 180);

  /// Format coordinates for display
  static String formatCoordinate(double coordinate, {int precision = 6}) {
    return coordinate.toStringAsFixed(precision);
  }

  /// Validate if coordinates are valid
  static bool isValidLatitude(double lat) {
    return lat >= -90 && lat <= 90;
  }

  static bool isValidLongitude(double lon) {
    return lon >= -180 && lon <= 180;
  }

  /// Check if coordinates represent a valid location
  static bool areValidCoordinates(double lat, double lon) {
    return isValidLatitude(lat) && isValidLongitude(lon);
  }
}
