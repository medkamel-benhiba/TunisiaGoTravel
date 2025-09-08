/*import 'package:latlong2/latlong.dart';
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
*/
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

Future<LatLng?> getCurrentLocation() async {
  // FOR TESTING ONLY - Fixed location in Tunisia (Tunis)
  // Remove this in production and uncomment the real location code below
  const testLocation = LatLng(36.8065, 10.1815); // Tunis, Tunisia
  print('Using test location: ${testLocation.latitude}, ${testLocation.longitude}');
  return testLocation;

  /* UNCOMMENT FOR REAL LOCATION IN PRODUCTION:

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

  */
}

bool _isDefaultLocation(LatLng location) {
  // Vérifier quelques coordonnées par défaut communes
  const defaultLocations = [
    LatLng(37.4219983, -122.084), // Google/Android default
    LatLng(0.0, 0.0), // Null Island
    LatLng(37.785834, -122.406417), // San Francisco default
  ];

  for (final defaultLoc in defaultLocations) {
    if ((location.latitude - defaultLoc.latitude).abs() < 0.01 &&
        (location.longitude - defaultLoc.longitude).abs() < 0.01) {
      return true;
    }
  }

  return false;
}