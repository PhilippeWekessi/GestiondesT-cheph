import 'package:flutter/material.dart';

import '../models/task.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority.label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}