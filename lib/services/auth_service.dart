import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static String? _token;

  /// spremi token u globalnu memoriju
  static void setToken(String token) {
    _token = token;
  }

  /// dohvat tokena
  static String? get token => _token;

  /// korisnik je prijavljen ako token postoji
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// odjava – samo obriši token
  static void logout() {
    _token = null;
  }
}

class TokenHelper {
  static String? getNameFromToken(String token) {
    if (token.isEmpty) return null;

    try {
      // Dekodira cijeli payload u Map
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Provjerite u debuggeru točan naziv ključa (key)
      // Često je 'name', 'preferred_username' ili 'unique_name'
      return decodedToken['sub'] ?? decodedToken['unique_name'] ?? "Korisnik";
    } catch (e) {
      print("Greška pri dekodiranju tokena: $e");
      return null;
    }
  }

  static bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
}
