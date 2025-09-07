import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

Future<LatLng?> getCurrentLocation() async {
  Location location = Location();
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) serviceEnabled = await location.requestService();
  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) return null;
  }
  final locData = await location.getLocation();
  return LatLng(locData.latitude!, locData.longitude!);
}
