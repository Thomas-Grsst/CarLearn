import 'geo_position.dart';
import 'location_access.dart';

abstract interface class LocationSource {
  Future<LocationAccess> checkAccess();
  Future<LocationAccess> requestAccess();
  Future<void> openSettings(LocationAccess access);
  Stream<GeoPosition> watch();
}
