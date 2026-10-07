import 'dart:io';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/user_profile.dart';

class UserAvatar extends StatelessWidget {
  final UserProfile user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final photo = user.photoPath;
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFCFD6EE),
      backgroundImage: photo != null ? FileImage(File(photo)) : null,
      child: photo == null
          ? Text(
              user.initials,
              style: TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}