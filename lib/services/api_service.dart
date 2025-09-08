import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunisiagotravel/models/maisondHote.dart';
import '../models/activity.dart';
import '../models/agil.dart';
import '../models/artisanat.dart';
import '../models/circuitManuel.dart';
import '../models/destination.dart';
import '../models/event.dart';
import '../models/festival.dart';
import '../models/guide.dart';
import '../models/hotel.dart';
import '../models/hotelAvailabilityResponse.dart';
import '../models/hotel_details.dart' hide Destination;
import '../models/listjour.dart';
import '../models/login.dart';
import '../models/monument.dart';
import '../models/musee.dart';
import '../models/restaurant.dart';
import '../models/success.dart';
import '../models/user.dart';
import '../models/voyage.dart';


class ApiService {
  static const String _baseUrl = 'https://backend.tunisiagotravel.com';
  final String _cachevoy = 'cached_voyages';

  Future<List<Destination>> getDestinations() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/utilisateur/alldestinations'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['destinations'];
      return data.map((json) => Destination.fromJson(json)).toList();
    } else {
      print('Failed to load destinations');
      throw Exception('Failed to load destinations');
    }
  }

  Future<List<Hotel>> gethotels() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/allhotels'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['hotels'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['hotels'] is List) {
          return (jsonData['hotels'] as List)
              .map((hotel) => Hotel.fromJson(hotel))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['hotels']}");
        }
      } else {
        throw Exception("Failed to fetch hotels: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in gethotels: $e");
      print("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<HotelDetail?> gethoteldetail(String slug) async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/hoteldetail/$slug'));
      print('$_baseUrl/utilisateur/hoteldetail/$slug');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['hotels'] == null) {
          throw Exception("API returned null data");
        }
        final List<dynamic>? hotels = jsonData['hotels'];

        final firstHotel = hotels!.first;

        if (firstHotel != null) {
          return HotelDetail.fromJson(firstHotel);
        } else {
          throw Exception("Unexpected data format: ${jsonData['hotels']}");
        }
      } else {
        throw Exception("Failed to fetch hotels: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in gethotels: $e");
      print("StackTrace: $stackTrace");
      return null;
    }
  }

  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/allrestaurants'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['restaurants'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['restaurants'] is List) {
          return (jsonData['restaurants'] as List)
              .map((r) => Restaurant.fromJson(r))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['restaurants']}");
        }
      } else {
        throw Exception("Failed to fetch restaurants: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getAllRestaurants: $e");
      print("StackTrace: $stackTrace");
      return []; // Return empty list on failure
    }
  }

  Future<List<MaisonDHote>> getmaisons() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/allmaison'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['maisons'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['maisons'] is List) {
          return (jsonData['maisons'] as List)
              .map((hotel) => MaisonDHote.fromJson(hotel))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['maisons']}");
        }
      } else {
        throw Exception("Failed to fetch maisons: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getMaison: $e");
      print("StackTrace: $stackTrace");
      return []; // Return empty list on failure
    }
  }

  Future<List<Activity>> getallactivitys() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/allactivity'));
      print('$_baseUrl/utilisateur/allactivity');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['activety'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['activety']['data'] is List) {
          return (jsonData['activety']['data'] as List)
              .map((hotel) => Activity.fromJson(hotel))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['events']}");
        }
      } else {
        throw Exception("Failed to fetch events: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getallactivitys: $e");
      print("StackTrace: $stackTrace");
      return []; // Return empty list on failure
    }
  }

  Future<List<Event>> getallevents() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/allevent'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['events'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['events']['data'] is List) {
          return (jsonData['events']['data'] as List)
              .map((hotel) => Event.fromJson(hotel))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['events']}");
        }
      } else {
        throw Exception("Failed to fetch events: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getallevents: $e");
      print("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<List<Guide>> getallguide() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/utilisateur/guide'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null) {
          throw Exception("API returned null data");
        }

        if (jsonData is List) {
          return (jsonData).map((guide) => Guide.fromJson(guide)).toList();
        } else {
          throw Exception("Unexpected data format: $jsonData");
        }
      } else {
        throw Exception("Failed to fetch guide: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getallguides: $e");
      print("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<List<Musees>> getmusee() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/musees'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['musees'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['musees']['data'] is List) {
          return (jsonData['musees']['data'] as List)
              .map((hotel) => Musees.fromJson(hotel))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['musees']}");
        }
      } else {
        throw Exception("Failed to fetch musees: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getmusees: $e");
      print("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<List<Artisanat>> getArtisanat() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/utilisateur/artisanat'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['data'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['data'] is List) {
          return (jsonData['data'] as List)
              .map((hotel) => Artisanat.fromJson(hotel))
              .toList();
        } else {
          throw Exception("Unexpected artisanat format: ${jsonData['data']}");
        }
      } else {
        throw Exception("Failed to fetch artisanat: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getartisanat: $e");
      print("StackTrace: $stackTrace");
      return []; // Return empty list on failure
    }
  }

  Future<List<Monument>> getmonument(String page) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/utilisateur/monument?page=$page'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['monument'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['monument']['data'] is List) {
          return (jsonData['monument']['data'] as List)
              .map((hotel) => Monument.fromJson(hotel))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['monument']}");
        }
      } else {
        throw Exception("Failed to fetch musees: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getmonument: $e");
      print("StackTrace: $stackTrace");
      return []; // Return empty list on failure
    }
  }

  Future<List<Festival>> getfestival([String page = "1"]) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/utilisateur/festival?page=$page'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['festival'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['festival']['data'] is List) {
          return (jsonData['festival']['data'] as List)
              .map((festival) => Festival.fromJson(festival))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['festival']}");
        }
      } else {
        throw Exception("Failed to fetch festival: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getfestival: $e");
      print("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<Musees> getMuseeBySlug(String slug) async {
    try {
      final encodedSlug = Uri.encodeComponent(slug);
      final url = Uri.parse('$_baseUrl/utilisateur/musees/$encodedSlug'); // note le chemin
      final response = await http.get(url);

      print("Request URL: $url");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return Musees.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Musée introuvable pour le slug: $slug');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print("Erreur getMuseeBySlug: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  Future<Monument> getMonumentBySlug(String slug) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/monument/$slug'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Monument.fromJson(data['monument'] ?? data);
    } else {
      throw Exception('Failed to load monument: ${response.statusCode}');
    }
  }

  Future<Artisanat> getArtisanatBySlug(String slug) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/artisanat/$slug'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Artisanat.fromJson(data['artisanat'] ?? data);
    } else {
      throw Exception('Failed to load artisanat: ${response.statusCode}');
    }
  }

  Future<Listjour> getcircuitauto(
      String budget,
      String start,
      String end,
      String depart,
      String arrive,
      String adult,
      String child,
      dynamic room,
      int def) async {
    final url = Uri.parse(
        '$_baseUrl/utilisateur/circuitsmobile');
    var body = json.encode({
      "budget": budget,
      "endDate": end,
      "startDate": start,
      "Vile_depart": depart,
      "Vile_arrive": arrive,
      "adults": adult,
      "children": child,
      "rooms": room,
      "duree": def
    });
    var headers = {'Content-Type': 'application/json'};

    print(
        ' url $_baseUrl/utilisateur/circuitsmobile body $body');

    final response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Listjour listjours = Listjour.fromJson(data);
      print('Circuit fetched successfully: $data');
      return listjours;
    } else {
      print('Error: Received status code ${response.statusCode}, body: ${response.body}');
    }

    return Listjour(
      listparjours: {},
      dipart: null,
      arriver: null,
      startDate: '',
      endDate: '',
      room: '',
      children: '',
      adults: '',
    );
  }

  Future<CircuitManuel> getcircuitmanulledes(
      String budget,
      String start,
      String end,
      String depart,
      String arrive,
      String adult,
      String child,
      String room,
      int def) async {
    final url = Uri.parse('$_baseUrl/utilisateur/newcircuit');

    var body = json.encode({
      "budget": budget,
      "endDate": end,
      "startDate": start,
      "Vile_depart": depart,
      "Vile_arrive": arrive,
      "adults": adult,
      "children": child,
      "rooms": room,
      "duree": def
    });

    var headers = {'Content-Type': 'application/json'};

    print('DEBUG getcircuitmanulledes - URL: $url');
    print('DEBUG getcircuitmanulledes - BODY: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('DEBUG getcircuitmanulledes - STATUS CODE: ${response.statusCode}');
    print('DEBUG getcircuitmanulledes - RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('DEBUG getcircuitmanulledes - Parsed Data: $responseData');
      return CircuitManuel.fromJson(responseData);
    }

    throw FormatException('Expected a list in the response body');
  }

  Future<Listjour> getcircuitmanulle(
      String budget,
      String start,
      String end,
      List<Map<String, dynamic>> destinations,
      String room,
      String adults,
      String child,
      ) async {
    final url = Uri.parse('$_baseUrl/utilisateur/createcircuit');

    // Construire la liste des destinations avec startedCity
    final formattedDestinations = destinations.map((d) {
      return {
        "destination_id": d['id'],
        "days": d['days'],
        "startedCity": d['isStart'] ?? false,
      };
    }).toList();

    final body = json.encode({
      "dateStart": start,
      "dateEnd": end,
      "destinations": formattedDestinations,
      "adults": int.parse(adults),
      "children": int.parse(child),
      "rooms": int.parse(room),
      "babies": 0,
      "total": int.parse(budget),
    });

    var headers = {'Content-Type': 'application/json'};

    print('DEBUG getcircuitmanulle - URL: $url');
    print('DEBUG getcircuitmanulle - BODY: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('DEBUG getcircuitmanulle - STATUS CODE: ${response.statusCode}');
    print('DEBUG getcircuitmanulle - RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print('DEBUG getcircuitmanulle - Parsed Data: $data');

        return Listjour.fromJson(data);
      } catch (e) {
        print('ERROR parsing JSON: $e');
      }
    } else {
      print('ERROR - HTTP status code: ${response.statusCode}');
    }

    return Listjour(
      listparjours: {},
      dipart: null,
      arriver: null,
      startDate: '',
      endDate: '',
      room: '',
      children: '',
      adults: '',
    );
  }


  //circuit prédifini
  Future<List<Voyage>> getAllVoyage() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/utilisateur/voyages'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['voyages'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['voyages'] is List) {
          final voyages = (jsonData['voyages'] as List)
              .map((v) => Voyage.fromJson(v))
              .toList();

          // Save to SharedPreferences cache
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(_cachevoy, jsonEncode(voyages.map((v) => v.toJson()).toList()));

          return voyages;
        } else {
          throw Exception("Unexpected data format: ${jsonData['voyages']}");
        }
      } else {
        throw Exception("Failed to fetch voyages: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getAllVoyage: $e");
      print("StackTrace: $stackTrace");

      // Try to load cached voyages if API fails
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachevoy);
      if (cachedData != null) {
        try {
          final List jsonList = jsonDecode(cachedData);
          return jsonList.map((v) => Voyage.fromJson(v)).toList();
        } catch (_) {
          print("Failed to load cached voyages");
        }
      }
      return [];
    }
  }

  //authentification

  Future<User?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/utilisateur/login');
    var body = json.encode({
      "email": email,
      "password": password,
    });
    var headers = {'Content-Type': 'application/json'};

    print('Success $url');
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print('Success d c $url $body ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Success d c $url ${response.body}');
      final prefs = await SharedPreferences.getInstance();

      // Decode the response body into a Map
      final Map<String, dynamic> decoded = json.decode(response.body);

      // Use fromJson from your Login model
      final Login login = Login.fromJson(decoded);

      // Save token and user
      prefs.setString("token", login.token ?? "");
      prefs.setString('user', json.encode(login.user));

      final user = login.user; // The actual User object
      return user;
    } else {
      throw Exception('Failed to post login: ${response.reasonPhrase}');
    }
  }


  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/utilisateur/registeruser'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'tel': phone,
        'ville': city,
        'privacy': "true",
      },
    );


    if (response.statusCode == 200) {
      // Store user ID in shared preferences
      Success success = Success(success: true);
      return success.success; // Registration successful
    } else {
      return false; // Registration failed
    }
  }

  //agil
  Future<List<Agil>> getagil() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/utilisateur/agil'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null || jsonData['agil'] == null) {
          throw Exception("API returned null agil");
        }

        if (jsonData['agil'] is List) {
          return (jsonData['agil'] as List)
              .map((agil) => Agil.fromJson(agil))
              .toList();
        } else {
          throw Exception("Unexpected agil format: ${jsonData['agil']}");
        }
      } else {
        throw Exception("Failed to fetch agil: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error in getagil: $e");
      print("StackTrace: $stackTrace");
      return []; 
    }
  }

  //hotel disponibility
  Future<List<Hotel>> getAvailableHotels({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required String adults,
    required String rooms,
    required String children,
    int babies = 0,
    int page = 1,

  }) async {
    try {
      final url = Uri.parse('$_baseUrl/utilisateur/hoteldisponible?page=$page');

      final requestBody = {
        'destination_id': destinationId,
        'date_start': dateStart,
        'date_end': dateEnd,
        'adults': adults,
        'rooms': rooms,
        'children': children,
        'babies': babies,
      };

      print('Request to hoteldisponible: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          List<Hotel> hotels;

          // Handle different response structures
          if (jsonData is List) {
            // Direct list of hotels
            hotels = List<Hotel>.from(jsonData.map((x) => Hotel.fromJson(x)));
          } else if (jsonData is Map<String, dynamic>) {
            if (jsonData.containsKey('data')) {
              final data = jsonData['data'];
              if (data is List) {
                hotels = List<Hotel>.from(data.map((x) => Hotel.fromJson(x)));
              } else {
                throw Exception(
                    'Expected data field to be a list, got: ${data.runtimeType}');
              }
            } else {
              hotels = [Hotel.fromJson(jsonData)];
            }
          } else {
            throw Exception(
                'Unexpected JSON structure: ${jsonData.runtimeType}');
          }

          return hotels;
        } catch (e) {
          print('JSON parsing error: $e');
          print('Response body: ${response.body}');
          print('Response status: ${response.statusCode}');
          print('Response headers: ${response.headers}');
          throw Exception('Failed to parse hotel data: $e');
        }
      } else {
        throw Exception(
            'Failed to load available hotels. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAvailableHotels: $e');
      throw Exception('Error checking hotel availability: $e');
    }
  }

  Future<HotelAvailabilityResponse> getHotelDisponibilityPontion({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/utilisateur/hoteldisponiblepontion?page=$page');

      debugPrint(
          'getHotelDisponibilityPontion called with dateStart=$dateStart, dateEnd=$dateEnd');

      final formattedRooms = rooms.map((room) {
        return {
          'adults': room['adults'],
          'children': room['children'],
          'childAges': room['childAges'] ?? [],
        };
      }).toList();

      final requestBody = {
        "destination_id": destinationId,
        "date_start": dateStart,
        "date_end": dateEnd,
        "rooms": formattedRooms,
      };

      debugPrint('POST $url with body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed with code: ${response.statusCode}');
      }

      final jsonResponse = json.decode(response.body);

      // Safe parsing of hotels
      final dataField = jsonResponse['data'];
      List<HotelData> hotels = [];

      if (dataField != null && dataField is List) {
        hotels = dataField
            .whereType<Map<String, dynamic>>()
            .map((hotelMap) => HotelData.fromJson(hotelMap))
            .toList();
      }

      return HotelAvailabilityResponse(
        currentPage: jsonResponse['current_page'] ?? 1,
        data: hotels,
        lastPage: jsonResponse['last_page'] ?? 1,
        nextPageUrl: jsonResponse['next_page_url'],
      );
    } catch (e) {
      throw Exception('Error fetching paginated hotels: $e');
    }
  }

  Future<Map<String, dynamic>> showMouradiDisponibility({
    required String hotelId,
    required String city,
    required String dateStart,
    required String dateEnd,
    required List<dynamic> rooms,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/utilisateur/Mouradi/showdisponibility');

      final requestBody = {
        'hotel_id': hotelId,
        'city': city,
        'date_start': dateStart,
        'date_end': dateEnd,
        'rooms': rooms,
      };

      debugPrint('Mouradi Availability Request: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint(
          'Mouradi Availability Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        if (responseBody.isEmpty || responseBody == '[]') {
          return {};
        }
        return jsonDecode(responseBody);
      } else {
        throw Exception(
            'Failed to load availability. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Mouradi Availability Error: $e');
      throw Exception('Error checking availability: $e');
    }
  }


  Future<Map<String, dynamic>?> sendVoiceQuestion(String message) async {
    final url = Uri.parse('$_baseUrl/utilisateur/askQuestion');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"];
      } else {
        print('Failed to send question: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending question: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> sendChatbotQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/utilisateur/askQuestion'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'question': question,
        }),
      );

      print('Chatbot API Response Status: ${response.statusCode}');
      print('Chatbot API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // Validate response structure
        if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        } else {
          print('Invalid response format: expected Map<String, dynamic>');
          return null;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network Error in sendChatbotQuestion: $e');
      return null;
    }
  }
  Future<dynamic> postHotelReservation(
      dynamic hotelId,
      dynamic startDate,
      dynamic endDate,
      dynamic adults,
      dynamic children,
      dynamic babies,
      dynamic name,
      dynamic email,
      dynamic phone,
      dynamic city,
      dynamic country,
      dynamic cin,
      List<String> accommodationIds,
      List<String> roomIds,
      List<int> quantities,
      dynamic totalPrice,
      List<Map<String, dynamic>> paxList,
      ) async {
    final url = '$_baseUrl/utilisateur/hotels/reservationhotel';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "name": name,
      "email": email,
      "phone": phone,
      "city": city,
      "country": country,
      "cin": cin,
      "hotel_id": hotelId,
      "date_start": startDate,
      "date_end": endDate,
      "adults": adults,
      "children": children,
      "babies": babies,
      "total_price": totalPrice,
      "accommodation_id": accommodationIds,
      "room_id": roomIds,
      "number": quantities.reduce((a, b) => a + b),
      "pax": paxList,
    });
    // 🔹 DEBUG: afficher URL, headers et body
    print('--- API REQUEST ---');
    print('POST $url');
    print('Headers: $headers');
    print('Body: $body');
    print('------------------');

    final response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    // 🔹 DEBUG: afficher response
    print('--- API RESPONSE ---');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    print('-------------------');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit reservation: ${response.body}');
    }
  }

  Future<dynamic> postHotelReservationBHR(Map<String, dynamic> reservationData) async {
    final url = '$_baseUrl/utilisateur/bhr/hotelsreservation';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(reservationData);

    print('POST $url');
    print('Body: $body');

    final response = await http.post(
      Uri.parse('https://test.tunisiagotravel.com/utilisateur/bhr/hotelsreservation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reservationData),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit BHR reservation: ${response.body}');
    }
  }

  Future<void> postHotelReservationMouradi(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("https://test.tunisiagotravel.com/utilisateur/Mouradi/book"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur réservation Mouradi: ${response.body}");
    }
  }

  Future<void> reserveHotelTgt(Map<String, dynamic> reservationData) async {
    final url = Uri.parse('$_baseUrl/utilisateur/hotels/reservationhotel');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(reservationData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reserve hotel: ${response.body}');
    }
  }




}


/*

  Future<HotelPreReservation> getHotelPreReservation({
    required String hotelId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
  }) async {
    final url = Uri.parse('$_baseUrl/utilisateur/bbx/hotelsprereservation');

    final requestBody = {
      "hotel_id": hotelId,
      "date_start": dateStart,
      "date_end": dateEnd,
      "rooms": rooms,
    };

    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return HotelPreReservation.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to fetch pre-reservation data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during pre-reservation: $e');
    }
  }





  // Future<List<Disponibility>> checkdispo(String slug, String start, String end, List aduilt) async {
  //   var headers = {'Content-Type': 'application/json'};
  //   var body = json.encode({
  //     'date_start': start,
  //     'date_end': end,
  //     'rooms': aduilt,
  //   });
  //
  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse('$_baseUrl/utilisateur/hotels/showDisponibility/$slug'),
  //           body: body,
  //           headers: headers,
  //         )
  //         .timeout(Duration(seconds: 30));
  //
  //     if (response.statusCode == 200) {
  //       List<Disponibility> data = disponibilityFromJson(response.body);
  //       return data;
  //     } else if (response.statusCode == 302) {
  //       String? redirectUrl = response.headers['location'];
  //       if (redirectUrl != null) {
  //         final redirectResponse = await http.post(
  //           Uri.parse(redirectUrl),
  //           body: body,
  //           headers: headers,
  //         );
  //         if (redirectResponse.statusCode == 200) {
  //           return disponibilityFromJson(redirectResponse.body);
  //         }
  //       }
  //       throw Exception('Redirect failed');
  //     } else {
  //       throw Exception('Request failed with status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error checking availability: $e');
  //   }
  // }

  Future<Success> postreservationhotel(
      String id,
      String? dateStart,
      String? dateEnd,
      String adults,
      String children,
      String name,
      String email,
      String phone,
      String city,
      String contry,
      List<String?> accommodationIds,
      List<String?> roomIds,
      List<int> number,
      String total) async {
    final url = Uri.parse('$_baseUrl/utilisateur/hotels/reservationhotel');

    var body = json.encode({
      "room_id": roomIds,
      "accommodation_id": accommodationIds,
      "number": number,
      "hotel_id": id,
      "date_start": dateStart,
      "date_end": dateEnd,
      "adults": adults,
      "children": children,
      "name": name,
      "email": email,
      "phone": phone,
      "city": city,
      "total_price": total,
      "country": contry
    });

    print(body);

    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print(" repence  ..........................   $responseBody");

      print('success');

      return Success(success: true);
    } else {
      print('Failed to post hotel : $body ${response.body}');
      // Return a Success instance with success set to false
      return Success(success: false);
    }
  }

  Future<Success> postreservationrestau(
      String id,
      String? date,
      String? time,
      String number,
      String name,
      String email,
      String phone,
      String country,
      String city) async {
    final url = Uri.parse('$_baseUrl/utilisateur/restaurants/reservation');

    var body = json.encode({
      "resetaurant_id": id,
      "date": date,
      "time": time,
      "name": name,
      "number": number,
      "email": email,
      "phone": phone,
      "country": country,
      "city": city,
    });

    var headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print(" repence  ..........................   $responseBody");
      Success success = Success(success: true);
      print('success');
      return success;
    } else {
      print(
          'Failed to post restaurtsa: ${response.statusCode} $body $_baseUrl/utilisateur/restaurants/reservation');
      // Return a Success instance with success set to false
      return Success(success: false);
    }
  }

  Future<Success> postreservationevet(
      String id,
      String? numberplaces,
      int price,
      String name,
      String email,
      String phone,
      String country,
      String city) async {
    final url = Uri.parse('$_baseUrl/utilisateur/reservationevent');

    var body = json.encode({
      "price": price,
      "event_id": id,
      "number": numberplaces,
      "name": name,
      "email": email,
      "phone": phone,
      "country": country,
      "city": city,
    });

    print('url $url   body$body');

    var headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print(" repence  ..........................   $responseBody");
      Success success = Success(success: true);
      print('success');
      return success;
    } else {
      print('Failed to post circuit: ${response.statusCode} ${response.body}');
      // Return a Success instance with success set to false
      return Success(success: false);
    }
  }

  Future<bool> destroyUser({required String id}) async {
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
        Uri.parse('$_baseUrl/utilisateur/user/destroy/$id'),
        headers: headers);

    final responseBody = jsonDecode(response.body);
    print(responseBody);
    if (response.statusCode == 200) {
      // Store user ID in shared preferences
      Success success = Success.fromJson(responseBody);
      return success.success; // Registration successful
    } else {
      return false; // Registration failed
    }
  }

  Future<Success> postreservationvoyage(
      String number, String date, String voyageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/utilisateur/voyages'),
      headers: headers,
      body: {
        'voyage_id': voyageId,
        'number_of_persons': number,
        'booking_date': date,
      },
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return Success(success: true);
    } else {
      print('hhhhhh $responseBody  ${response.statusCode}');
    }

    return Success(success: false);
  }

  Future<List<Hoteldispon>> cherche(
      String start, String end, List rooms, String destinationId) async {
    int children = 0;
    int adults = 0;

    for (var roome in rooms) {
      adults += (roome['adults'] as num).toInt();
      children += (roome['children'] as num).toInt();
    }

    // Format dates to DD-MM-YYYY as backend expects this format
    String formatDate(String isoDate) {
      try {
        final date = DateTime.parse(isoDate);
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      } catch (e) {
        print('Error formatting date: $e');
        return isoDate; // fallback to original if parsing fails
      }
    }

    final formattedStart = formatDate(start);
    final formattedEnd = formatDate(end);

    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({
      'date_start': formattedStart,
      'date_end': formattedEnd,
      'adults': adults,
      'children': children,
      'babies': "0",
      'rooms': rooms,
      'destination_id': destinationId,
      'hotel_type':
          'mouradi' // Add this parameter to request only Mouradi hotels
    });

    print('Search request body: $body');
    print('POST $_baseUrl/utilisateur/hoteldisponible');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/utilisateur/hoteldisponible'),
        body: body,
        headers: headers,
      );

      print('Search Response status: ${response.statusCode}');
      print('Search Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<Hoteldispon> hotels = HoteldisponFromJson(response.body);

        // Filter only Mouradi hotels (double check - backend should handle this now)
        hotels = hotels
            .where(
                (h) => h.idHotelMouradi != null && h.idHotelMouradi!.isNotEmpty)
            .toList();

        print('Found ${hotels.length} Mouradi hotels');
        for (var hotel in hotels) {
          print(
              'Mouradi Hotel: ${hotel.name}, ID: ${hotel.idHotelMouradi}, City: ${hotel.ville}');
        }

        return hotels;
      } else {
        // Handle HTML error responses
        if (response.body.contains('<!DOCTYPE html>')) {
          throw Exception(
              'Server returned HTML error page. Please check the date format.');
        } else {
          throw Exception(
              'API error: ${response.statusCode} - ${response.body}');
        }
      }
    } on FormatException catch (e) {
      print('Date Format Error: $e');
      throw Exception('Invalid date format. Please use YYYY-MM-DD format.');
    } on http.ClientException catch (e) {
      print('Network Error: $e');
      throw Exception('Network error occurred. Please check your connection.');
    } catch (e) {
      print('Search Error: $e');
      throw Exception('Error in cherch(): $e');
    }
  }



  // Future<Success> postreservation(Listjour listjour, dynamic user, List<List<Disponibility>> selectedDisponibilityList) async {
  //   final url = Uri.parse(
  //       '$_baseUrl/utilisateur/reservationcercuitmobil');
  //
  //   // Convert the iterable to a list
  //   Map<String, dynamic> planing = {
  //     'alldestination': listjour.alldestination,
  //     'listparjours': listjour.listparjours,
  //   };
  //
  //   var headers = {'Content-Type': 'application/json'};
  //   List<Map<String, dynamic>> items = [];
  //   for (var i = 1; i < selectedDisponibilityList.length; i++) {
  //     var innerList = selectedDisponibilityList[i];
  //
  //     if (innerList.isNotEmpty) {
  //       for (var entry in listjour.listparjours.entries) {
  //         if (int.parse(entry.key) == i) {
  //           Map<String, dynamic>? jsonItem = entry.value.hotel?[0].toJson();
  //           jsonItem!['rooms'] = innerList;
  //
  //           items.add(jsonItem!);
  //         }
  //       }
  //     }
  //   }
  //   Map<String, dynamic> reservation = {
  //     'departureCity': listjour.alldestination,
  //     'arrivalCity': listjour.listparjours,
  //     "adults": listjour.adults,
  //     "children": listjour.children,
  //     "rooms": listjour.room,
  //     "babies": 0,
  //     "budget": 0,
  //     "departureDate": listjour.startDate,
  //     "arrivalDate": listjour.endDate
  //   };
  //
  //   Map<String, dynamic> body = {
  //     'planing': planing,
  //     'hotelsReservation': items,
  //     'restaurantReservation': [],
  //     'user': user,
  //     'reservation': reservation,
  //   };
  //
  //   print('Failed to post circuit: ${jsonEncode(listjour.listparjours)} ');
  //
  //   final response = await http.post(
  //     url,
  //     headers: headers,
  //     body: jsonEncode(body),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final responseBody = json.decode(response.body);
  //
  //     Success success = Success.fromJson(responseBody);
  //
  //     return success;
  //   } else {
  //     print('Failed to post circuit: ${response.statusCode} ${response.body}');
  //     return Success(success: false);
  //   }
  // }

  Future<List<Hotel>> cherchedispo(
      String start, String end, List rooms, String destinationId,
      [int page = 1]) async {
    int children = 0;
    int adults = 0;

    for (var roome in rooms) {
      adults += (roome['adults'] as num).toInt();
      children += (roome['children'] as num).toInt();
    }

    // Format dates to DD-MM-YYYY as backend expects this format
    String formatDate(String isoDate) {
      try {
        final date = DateTime.parse(isoDate);
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      } catch (e) {
        print('Error formatting date: $e');
        return isoDate; // fallback to original if parsing fails
      }
    }

    final formattedStart = formatDate(start);
    final formattedEnd = formatDate(end);

    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({
      'date_start': formattedStart,
      'date_end': formattedEnd,
      'adults': adults,
      'children': children,
      'babies': "0",
      'rooms': rooms,
      'destination_id': destinationId,
    });

    print('Search request body: $body');
    print('POST $_baseUrl/utilisateur/hoteldisponible?page=$page');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/utilisateur/hoteldisponible?page=$page'),
        body: body,
        headers: headers,
      );

      print('Search Response status: ${response.statusCode}');
      print('Search Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          List<Hotel> hotels;

          print('JSON data type: ${jsonData.runtimeType}');
          print('JSON data: $jsonData');

          // Handle different response structures
          if (jsonData is List) {
            // Direct list of hotels
            print('Processing as List with ${jsonData.length} items');
            hotels = [];
            for (var item in jsonData) {
              try {
                if (item is Map<String, dynamic>) {
                  hotels.add(Hotel.fromJson(item));
                } else {
                  print('Skipping non-map item: $item');
                }
              } catch (e) {
                print('Error parsing hotel item: $e');
                print('Item: $item');
              }
            }
          } else if (jsonData is Map<String, dynamic>) {
            print('Processing as Map with keys: ${jsonData.keys.toList()}');

            // Check if response has a 'data' field containing the hotels
            if (jsonData.containsKey('data')) {
              final data = jsonData['data'];
              print('Data field type: ${data.runtimeType}');

              if (data is List) {
                print('Processing data as List with ${data.length} items');
                hotels = [];
                for (var item in data) {
                  try {
                    if (item is Map<String, dynamic>) {
                      hotels.add(Hotel.fromJson(item));
                    } else {
                      print('Skipping non-map item in data: $item');
                    }
                  } catch (e) {
                    print('Error parsing hotel item in data: $e');
                    print('Item: $item');
                  }
                }
              } else if (data is Map<String, dynamic>) {
                // Single hotel in data field
                print('Processing data as single hotel');
                hotels = [Hotel.fromJson(data)];
              } else {
                throw Exception(
                    'Expected data field to be a list or map, got: ${data.runtimeType}');
              }
            } else {
              // Single hotel object
              print('Processing as single hotel object');
              hotels = [Hotel.fromJson(jsonData)];
            }
          } else {
            throw Exception(
                'Unexpected JSON structure: ${jsonData.runtimeType}');
          }

          print('Successfully parsed ${hotels.length} hotels');
          return hotels;
        } catch (e) {
          print('JSON parsing error: $e');
          print('Response body: ${response.body}');
          print('Response status: ${response.statusCode}');
          print('Response headers: ${response.headers}');
          throw Exception('Failed to parse hotel data: $e');
        }
      } else {
        // Handle HTML error responses
        if (response.body.contains('<!DOCTYPE html>')) {
          throw Exception(
              'Server returned HTML error page. Please check the date format.');
        } else {
          throw Exception(
              'API error: ${response.statusCode} - ${response.body}');
        }
      }
    } on FormatException catch (e) {
      print('Date Format Error: $e');
      throw Exception('Invalid date format. Please use YYYY-MM-DD format.');
    } on http.ClientException catch (e) {
      print('Network Error: $e');
      throw Exception('Network error occurred. Please check your connection.');
    } catch (e) {
      print('Search Error 1: $e');
      throw Exception('Error in cherch(): $e');
    }
  }
*/


