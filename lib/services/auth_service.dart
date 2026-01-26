// ignore: deprecated_member_use
import 'dart:html';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  static void setToken(String token) => window.localStorage[_tokenKey] = token;
  static String? get token => window.localStorage[_tokenKey];
  static bool get isLoggedIn => token != null && token!.isNotEmpty;
  static void logout() => window.localStorage.remove(_tokenKey);
}

// Klasa mora biti izvan AuthService-a!
class TokenHelper {
  static String? getNameFromToken(String token) {
    if (token.isEmpty) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      // 'sub' je standard za username, ali provjeri backend
      return decodedToken['sub'] ?? decodedToken['unique_name'] ?? "Korisnik";
    } catch (e) {
      print("Greška dekodiranja: $e");
      return null;
    }
  }
}