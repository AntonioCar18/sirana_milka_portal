import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FetchPartners {
  static Future<List<dynamic>> getPartners(String token) async {
    final url = Uri.parse(
      'http://app.sirana-milka.hr:8081/milkaservice/api/partner/all-partners'
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> responseData = jsonDecode(decodedBody);
        final List<dynamic> data = responseData['partners'];

        return data.map((partner) => {
          'id': partner['id'],
          'name': partner['partnerName'] ?? '',
          'oib': partner['oib'] ?? '',
          'email': partner['emailAddress'] ?? '',
          'address': partner['address'] ?? '',
          'contact_person': partner['contactPerson'] ?? '',
          'phone': partner['phoneNumber'] ?? '',
        }).toList();
      } else {
        throw Exception('Failed to load partners');
      }
    } catch (e) {
      throw Exception('Error fetching partners: $e');
    }
  }
}