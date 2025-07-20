import 'package:flutter/material.dart';

class RegistrationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRegistered;

  const RegistrationButton({
    super.key,
    required this.onPressed,
    required this.isRegistered,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(isRegistered ? 'Unregister' : 'Register'),
    );
  }
} 