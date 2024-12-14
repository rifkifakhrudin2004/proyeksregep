import 'package:flutter/material.dart';

class SkincareRoutineEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face,
            size: 120,
            color: Colors.pink[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No Skincare Routines Yet',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.pink[800]),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your first routine and start tracking\nyour skincare journey',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.pink[600],
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}