import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthService {
  // Register a new user
  Future<ParseResponse> register(
    String username,
    String email,
    String password,
  ) async {
    final user = ParseUser(
      username.trim(),
      password,
      email.trim(),
    );

    return await user.signUp();
  }

  // Login an existing user
  Future<ParseResponse> login(
    String username,
    String password,
  ) async {
    final user = ParseUser(
      username.trim(),
      password,
      null,
    );

    return await user.login();
  }

  // Logout the current user
  Future<ParseResponse?> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;

    if (user != null) {
      return await user.logout();
    }

    return null;
  }

  // Get the currently logged-in user
  Future<ParseUser?> getCurrentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }
}