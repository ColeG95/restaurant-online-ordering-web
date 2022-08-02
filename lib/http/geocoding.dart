import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:order_online/constants.dart';
import 'package:order_online/models/coordinates.dart';

class Geocoding {
  Future<Coordinates> addressToCoordinates(String address) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${address.replaceAll(' ', '+')}&key=${dotenv.env['GOOGLE_API_KEY']}');
    final response = await http.post(url);
    final relevantBody =
        json.decode(response.body)['results'][0]['geometry']['location'];
    return Coordinates(
        latitude: relevantBody['lat'], longitude: relevantBody['lng']);
  }
}
