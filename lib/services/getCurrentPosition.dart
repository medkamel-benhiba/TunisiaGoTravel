import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

Future<LatLng?> getCurrentLocation() async {
  Location location = Location();

  // Vérifier si le service de localisation est activé
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    print('Location service is disabled, requesting to enable...');
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      print('Location service still disabled after request');
      return null;
    }
  }

  // Vérifier les permissions
  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    print('Location permission denied, requesting permission...');
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      print('Location permission not granted: $permissionGranted');
      return null;
    }
  }

  try {
    // Configure high accuracy settings
    await location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 5000,
      distanceFilter: 10,
    );
    print('Location settings configured for high accuracy');

    // Obtenir la localisation actuelle avec des paramètres de précision
    final locData = await location.getLocation();

    if (locData.latitude == null || locData.longitude == null) {
      print('Location data is null');
      return null;
    }

    final result = LatLng(locData.latitude!, locData.longitude!);
    print('Got location: ${result.latitude}, ${result.longitude}');
    print('Location accuracy: ${locData.accuracy}m');
    print('Location timestamp: ${locData.time}');

    // Vérifier si la localisation semble être une valeur par défaut ou invalide
    if (_isDefaultLocation(result)) {
      print('Warning: Location seems to be a default/mock location');
    }

    return result;
  } catch (e) {
    print('Error getting current location: $e');
    return null;
  }
}

bool _isDefaultLocation(LatLng location) {
  // Vérifier quelques coordonnées par défaut communes
  const defaultLocations = [
    LatLng(33.8065, 10.1815),
  ];

  for (final defaultLoc in defaultLocations) {
    if ((location.latitude - defaultLoc.latitude).abs() < 0.01 &&
        (location.longitude - defaultLoc.longitude).abs() < 0.01) {
      return true;
    }
  }

  return false;
}