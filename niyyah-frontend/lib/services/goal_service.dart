import 'dart:convert';
import '../services/api_client.dart';
import '../models/goal.dart';

class GoalService {
  Future<List<Goal>> getGoals() async {
    final response = await ApiClient.get('/goals');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Goal.fromJson(json)).toList();
  }

  Future<Goal> createGoal(Map<String, dynamic> body) async {
    final response = await ApiClient.post('/goals', body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('CREATE RESPONSE: ${response.statusCode} — ${response.body}');
      return Goal.fromJson(jsonDecode(response.body));
    } else {
      print('CREATE RESPONSE: ${response.statusCode} — ${response.body}');
      throw Exception('Failed to create goal: ${response.body}');
    }
  }

  Future<Goal> updateGoal(int id, Map<String, dynamic> body) async {
    final response = await ApiClient.put('/goals/$id', body);
    return Goal.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteGoal(int id) async {
    await ApiClient.delete('/goals/$id');
  }

  Future<Goal> logHabit(int goalId) async {
  final response = await ApiClient.post('/goals/$goalId/log', {});

  if (response.statusCode == 200 || response.statusCode == 409) {
    // Both success AND "already logged" return the full goal — decode it
    final body = jsonDecode(response.body);
    return Goal.fromJson(body['goal']);
  }

  throw Exception('Failed to log habit: ${response.body}');
}

  Future<Goal> completeGoal(int id) async {
    final response = await ApiClient.post('/goals/$id/complete', {});
    return Goal.fromJson(jsonDecode(response.body));
  }
}