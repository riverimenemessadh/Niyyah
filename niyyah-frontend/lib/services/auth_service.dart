import 'dart:convert';
import '../services/api_client.dart';

class AuthService {
  // REGISTER
  // Returns null on success, returns error message string on failure
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      final data = jsonDecode(response.body);
      print('STATUS: ${response.statusCode}');
print('BODY: ${response.body}');

      if (response.statusCode == 201) {
        // Save the token so all future requests are authenticated
        await ApiClient.saveToken(data['token']);
        return null; // null means success
      } else {
        // Laravel returns validation errors as a map
        // We extract the first error message to show to the user
        final errors = data['errors'];
        if (errors != null) {
          final firstError = (errors as Map).values.first;
          return firstError is List ? firstError.first : firstError.toString();
        }
        return data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      return 'Connection error. Is the server running?';
    }
  }

  // LOGIN
  // Returns null on success, returns error message string on failure
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    // Always clear any existing token before attempting login.
    // This prevents a failed login from riding on a previously
    // saved token and incorrectly entering the app.
    await ApiClient.deleteToken();

    try {
      final response = await ApiClient.post('/login', {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await ApiClient.saveToken(data['token']);
        return null; // success
      } else {
        final errors = data['errors'];
        if (errors != null) {
          final firstError = (errors as Map).values.first;
          return firstError is List ? firstError.first : firstError.toString();
        }
        return data['message'] ?? 'Login failed';
      }
    } catch (e) {
      return 'Connection error. Is the server running?';
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    try {
      // Tell the server to invalidate the token
      await ApiClient.post('/logout', {});
    } catch (e) {
      // Even if server call fails, we delete the local token
    }
    await ApiClient.deleteToken();
  }

  // GET CURRENT USER
  // Returns the user data map, or null if not logged in
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.get('/me');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // CHECK IF LOGGED IN
  // Just checks if a token is saved locally
  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getToken();
    return token != null;
  }

  // UPDATE NAME
  // Sends the new name to the server and returns null on success,
  // or an error message string on failure
  static Future<String?> updateName(String name) async {
    try {
      final response = await ApiClient.put('/user', {'name': name});
      if (response.statusCode == 200) return null;
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Failed to update name';
    } catch (e) {
      return 'Connection error. Is the server running?';
    }
  }

  // DELETE ACCOUNT
  // Permanently deletes the user's account and clears the local token
  static Future<void> deleteAccount() async {
    await ApiClient.delete('/user');
    await ApiClient.deleteToken();
  }
}