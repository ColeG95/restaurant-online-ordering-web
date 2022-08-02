import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:order_online/models/coordinates.dart';
import 'package:order_online/models/route_info.dart';

class TravelInfo {
  static const String baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  Future<RouteInfo> getTravelInfo(
    Coordinates origin,
    Coordinates destination,
  ) async {
    final url = Uri.parse(
        '${dotenv.env['PROXY']}${baseUrl}origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${dotenv.env['GOOGLE_API_KEY']}');

    final response = await http.get(url);

    final relevantBody = json.decode(response.body)['routes'][0]['legs'][0];

    return RouteInfo(
      distanceText: relevantBody['distance']['text'],
      distanceValue: relevantBody['distance']['value'],
      durationText: relevantBody['duration']['text'],
      durationSeconds: relevantBody['duration']['value'],
    );
  }
}
