import 'package:flutter/material.dart';

enum Priority {
  high('Élevée', Color(0xFFE53935), '#E53935'),
  medium('Moyenne', Color(0xFFFB8C00), '#FB8C00'),
  low('Basse', Color(0xFF43A047), '#43A047');

  final String label;
  final Color color;
  final String hex; // couleur envoyée à l'API
  const Priority(this.label, this.color, this.hex);

  /// Convertit la priorité reçue de l'API (texte libre) en enum
  static Priority fromApi(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v.contains('lev') || v.contains('high') || v.contains('haute') || v.contains('urgent')) {
      return Priority.high;
    }
    if (v.contains('moy') || v.contains('med')) {
      return Priority.medium;
    }
    return Priority.low;
  }
}

class Task {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final Priority priority;

  const Task({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.priority,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawDate = json['dueDate'] ?? json['createdAt'];
    return Task(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      date: (rawDate != null ? DateTime.tryParse(rawDate.toString())?.toLocal() : null) ??
          DateTime.now(),
      priority: Priority.fromApi(json['priority']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'priority': priority.label,
        'color': priority.hex,
        'dueDate': date.toUtc().toIso8601String(),
      };
}