import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String avatarUrl;
  final double radius;
  final Color borderColor;

  const CustomAvatar({
    Key? key,
    required this.avatarUrl,
    this.radius = 30,
    this.borderColor = const Color.fromRGBO(255, 192, 203, 0.3), // Soft pink border
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : AssetImage('assets/default_avatar.png') as ImageProvider,
        backgroundColor: Colors.white,
      ),
    );
  }
}