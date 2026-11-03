import 'package:geolocator/geolocator.dart';

import 'geo_position.dart';
import 'location_access.dart';
import 'location_source.dart';

class GeolocatorLocationSource implements LocationSource {
  const GeolocatorLocationSource();

  static const int _distanceFilterMeters = 10;

  @override
  Future<LocationAccess> checkAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    return _accessFrom(await Geolocator.checkPermission());
  }

  @override
  Future<LocationAccess> requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _accessFrom(permission);
  }

  @override
  Future<void> openSettings(LocationAccess access) async {
    if (access == LocationAccess.serviceDisabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    await Geolocator.openAppSettings();
  }

  @override
  Stream<GeoPosition> watch() => Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: _distanceFilterMeters,
          intervalDuration: const Duration(seconds: 1),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Alertes radars actives',
            notificationText: 'En route te prévient 1 km avant chaque radar fixe.',
            enableWakeLock: true,
            setOngoing: true,
          ),
        ),
      ).map((position) => GeoPosition(
            latitude: position.latitude,
            longitude: position.longitude,
            headingDegrees: position.heading,
            speedMetersPerSecond: position.speed,
          ));

  LocationAccess _accessFrom(LocationPermission permission) => switch (permission) {
        LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
        LocationPermission.denied || LocationPermission.unableToDetermine => LocationAccess.denied,
        LocationPermission.deniedForever => LocationAccess.blocked,
      };
}
