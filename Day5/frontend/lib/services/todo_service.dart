import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'auth_service.dart';

class TodoItem {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  TodoItem({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}

class TodoService {
  final AuthService _auth = AuthService();

  Future<List<TodoItem>> getTodos() async {
    final response = await http.get(
      Uri.parse(AppConstants.todos),
      headers: await _auth.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => TodoItem.fromJson(json)).toList();
    }
    throw Exception('Failed to load todos');
  }

  Future<TodoItem> createTodo(String title, String description) async {
    final response = await http.post(
      Uri.parse(AppConstants.todos),
      headers: await _auth.getAuthHeaders(),
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 201) {
      return TodoItem.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create todo');
  }

  Future<void> updateTodo(int id, TodoItem todo) async {
    final response = await http.put(
      Uri.parse('${AppConstants.todos}/$id'),
      headers: await _auth.getAuthHeaders(),
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> deleteTodo(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.todos}/$id'),
      headers: await _auth.getAuthHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo');
    }
  }
}
