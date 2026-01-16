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
