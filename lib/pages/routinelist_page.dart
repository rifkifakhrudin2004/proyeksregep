import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'routine_page.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; //
import 'package:proyeksregep/models/skincare_model.dart';

class SkincareRoutineListPage extends StatefulWidget {
  @override
  _SkincareRoutineListPageState createState() =>
      _SkincareRoutineListPageState();
}

class _SkincareRoutineListPageState extends State<SkincareRoutineListPage> {
  List<SkincareRoutine> routines = []; // Data skincare routines yang disimpan

 @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }
  void _fetchRoutines() {
     User? currentUser = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (currentUser == null) {
      // Handle case when no user is logged in
      setState(() {
        routines = [];
      });
      return;
    }
 FirebaseFirestore.instance
        .collection('skincare_routines')
        .where('userId', isEqualTo: currentUser.uid) // Filter by user ID
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        routines = querySnapshot.docs.map((doc) {
          return SkincareRoutine(
            id: doc.id,
            userId: currentUser.uid, // Add userId
            avatarUrl: doc['avatarUrl'] ?? '',
            category: doc['category'],
            note: doc['note'],
            mondayMorning: doc['mondayMorning'],
            mondayNight: doc['mondayNight'],
            tuesdayMorning: doc['tuesdayMorning'],
            tuesdayNight: doc['tuesdayNight'],
            wednesdayMorning: doc['wednesdayMorning'],
            wednesdayNight: doc['wednesdayNight'],
            thursdayMorning: doc['thursdayMorning'],
            thursdayNight: doc['thursdayNight'],
            fridayMorning: doc['fridayMorning'],
            fridayNight: doc['fridayNight'],
            saturdayMorning: doc['saturdayMorning'],
            saturdayNight: doc['saturdayNight'],
            sundayMorning: doc['sundayMorning'],
            sundayNight: doc['sundayNight'],
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Skincare Routines'),
      ),
      body: ListView.builder(
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return Card(
            child: ListTile(
              leading: _buildAvatar(routine.avatarUrl),
              title: Text(routine.category),
              subtitle: Text(routine.note),
              trailing: Icon(Icons.edit),
              onTap: () async {
                final updatedRoutine = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SkincareRoutineInputPage(
                      routine: routine,
                    ),
                  ),
                );
                if (updatedRoutine != null) {
                  setState(() {
                  int index = routines.indexWhere((r) => r.id == updatedRoutine.id);
                  if (index != -1) {
                  routines[index] = updatedRoutine;
                      } 
                  });
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Check if user is logged in before navigating to input page
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            // Show login required dialog
            _showLoginRequiredDialog();
            return;
          }

          final newRoutine = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkincareRoutineInputPage(),
            ),
          );
          if (newRoutine != null) {
            setState(() {
              routines.add(newRoutine); // Add new routine to the list
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Show dialog when login is required
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('Please log in to add or view skincare routines.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, navigate to login page
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method to build avatar with proper image handling
  Widget _buildAvatar(String avatarUrl) {
    return CircleAvatar(
      radius: 25, // Adjusted size
      backgroundImage: _getImageProvider(avatarUrl),
      child: avatarUrl.isEmpty ? Icon(Icons.camera_alt) : null,
    );
  }

  // Helper method to get appropriate ImageProvider
  ImageProvider _getImageProvider(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return NetworkImage('https://www.example.com/default-avatar.jpg');
    }
    
    // Check if it's a local file path
    if (avatarUrl.startsWith('/')) {
      return FileImage(File(avatarUrl));
    }
    
    // Assume it's a network URL
    return NetworkImage(avatarUrl);
  }
}