import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  const UserAvatar({super.key, this.name, this.imageUrl});

  String getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl!),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.brown[100],
      child: Text(
        getInitials(name),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 18),
      ),
    );
  }
} 