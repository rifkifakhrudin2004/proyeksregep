import 'package:flutter/material.dart';

class EmptyRoutineState extends StatelessWidget {
  const EmptyRoutineState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity, 
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 1), 
                borderRadius: BorderRadius.circular(12), 
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.pink[800]),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}