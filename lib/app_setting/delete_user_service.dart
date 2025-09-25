import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../storage/token_storage.dart';


class DeleteUserService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Delete the currently logged-in user
  static Future<Map<String, dynamic>> deleteUser() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception("No auth token found");
    }

    final url = Uri.parse("$_baseUrl/user_delete.php");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to delete user. Code: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }
}
