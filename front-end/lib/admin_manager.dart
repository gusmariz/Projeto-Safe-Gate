import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminManager {
  final String token;

  AdminManager(this.token);

  Future<List<Map<String, dynamic>>> fetchUsuarios() async {
    final response = await http.get(
      Uri.parse(
          'https://projeto-safe-gate-production.up.railway.app/admin/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao carregar usuários');
    }
  }

  Future<void> deleteUsuario(String email) async {
    final response = await http.delete(
      Uri.parse(
          'https://projeto-safe-gate-production.up.railway.app/admin/users/:$email'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir usuário');
    }
  }
}
