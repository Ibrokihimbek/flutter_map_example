import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

enum LocationPermissionHandle { denied, locationEnabled, success }

mixin class LocationMixin {
  LocationMixin._();

  static LocationMixin get instance => LocationMixin._();
  final Location location = Location();

  Future<LocationPermissionHandle> hasPermission() async {
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied || permission == geo.LocationPermission.deniedForever) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied || permission == geo.LocationPermission.deniedForever) {
        return LocationPermissionHandle.denied;
      }
    }
    final bool serEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serEnabled) {
      return LocationPermissionHandle.locationEnabled;
    }
    return LocationPermissionHandle.success;
  }

  Future<bool> permission() async {
    late PermissionStatus permissionGranted;

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied || permissionGranted == PermissionStatus.deniedForever) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.denied || permissionGranted != PermissionStatus.deniedForever) {
        return false;
      }
    }
    return location.serviceEnabled();
  }

  Future<LatLng> determinePosition() async {
    if (!await permission()) {
      return determinePosition();
    }
    final position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.low,
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<bool> isRequestService() async {
    if (!(await location.serviceEnabled())) {
      return location.requestService();
    }
    return true;
  }
}

class Points {
  const Points({required this.latitude, required this.longitude});

  /// The point's latitude.
  final double latitude;

  /// The point's longitude
  final double longitude;

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'long': longitude,
  };
}
