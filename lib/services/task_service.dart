import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/task.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

String errorMessage(Object e) =>
    e is ApiException ? e.message : 'Une erreur est survenue';

class TaskService {
  /// Choisit automatiquement l'adresse selon la plateforme.
  /// Téléphone réel : remplace par l'IP de ton PC (ex : 'http://192.168.1.10:3000')
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000'; // émulateur Android
    }
    return 'http://localhost:3000'; // Windows, iOS simulateur
  }

  static const String _tasksPath = '/task';

  static const Duration _timeout = Duration(seconds: 10);
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _uri([String suffix = '']) => Uri.parse('$baseUrl$_tasksPath$suffix');

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final res = await request().timeout(_timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException('Erreur serveur (${res.statusCode})');
      }
      return res;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Le serveur ne répond pas');
    } catch (_) {
      throw const ApiException('Impossible de joindre le serveur');
    }
  }

  /// Certaines API renvoient directement l'objet, d'autres {"data": {...}}
  Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      return data is Map<String, dynamic> ? data : body;
    }
    throw const ApiException('Réponse inattendue du serveur');
  }

  /// Lire : récupérer la liste des tâches
  Future<List<Task>> getTasks() async {
    final res = await _send(() => http.get(_uri(), headers: _headers));
    final body = jsonDecode(res.body);
    final list =
        body is List ? body : (body is Map ? (body['data'] as List? ?? []) : []);
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Créer une tâche
  Future<Task> createTask(Task task) async {
    final res = await _send(
      () => http.post(_uri(), headers: _headers, body: jsonEncode(task.toJson())),
    );
    return Task.fromJson(_asMap(jsonDecode(res.body)));
  }

  /// Modifier une tâche (PATCH, confirmé par Swagger)
  Future<Task> updateTask(Task task) async {
    final res = await _send(
      () => http.patch(
        _uri('/${task.id}'),
        headers: _headers,
        body: jsonEncode(task.toJson()),
      ),
    );
    try {
      return Task.fromJson(_asMap(jsonDecode(res.body)));
    } catch (_) {
      return task; // l'API n'a pas renvoyé la tâche : on garde la nôtre
    }
  }

  /// Supprimer une tâche
  Future<void> deleteTask(String id) async {
    await _send(() => http.delete(_uri('/$id'), headers: _headers));
  }
}